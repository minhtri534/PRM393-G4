import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { createServer } from 'http';
import jwt from 'jsonwebtoken';
import { Server } from 'socket.io';
import axios from 'axios';

dotenv.config();

const port = Number(process.env.PORT || 5001);
const apiBaseUrl = (process.env.API_URL || 'http://localhost:5000/api').replace(/\/$/, '');
const backendOrigin = (process.env.BACKEND_URL || 'http://localhost:5000').replace(/\/$/, '');
const jwtSigningKey = process.env.JWT_SIGNING_KEY || '';
const jwtIssuer = process.env.JWT_ISSUER || 'DLSS';
const jwtAudience = process.env.JWT_AUDIENCE || 'DLSS';
const internalEmitKey = process.env.INTERNAL_EMIT_KEY || 'DLSS_DEV_REALTIME_INTERNAL_KEY';

if (!jwtSigningKey || jwtSigningKey.length < 32) {
  console.warn('[realtime] JWT_SIGNING_KEY is missing or too short. Socket auth will fail.');
}

const app = express();
app.use(cors({ origin: true, credentials: true }));
app.get('/health', (_req, res) => res.json({ ok: true }));

// Single public URL (e.g. ngrok): proxy REST API to ASP.NET backend on the same host.
app.use(
  '/api',
  createProxyMiddleware({
    target: backendOrigin,
    changeOrigin: true,
    pathRewrite: (path) => `/api${path}`,
  }),
);

const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: { origin: true, credentials: true },
});

function verifyToken(token) {
  if (!token) return null;
  try {
    const payload = jwt.verify(token, jwtSigningKey, {
      issuer: jwtIssuer,
      audience: jwtAudience,
    });
    const userId = payload.sub || payload.userId;
    if (!userId) return null;
    return {
      userId: String(userId),
      email: payload.email ? String(payload.email) : undefined,
    };
  } catch {
    return null;
  }
}

async function fetchAccessibleProjectIds(token) {
  const response = await axios.get(`${apiBaseUrl}/chat/projects`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const body = response.data;
  if (!body?.isSuccess || !Array.isArray(body.data)) {
    return [];
  }
  return body.data.map((p) => p.id).filter(Boolean);
}

async function ensureProjectAccess(token, projectId, cache) {
  if (!cache.projectIds) {
    cache.projectIds = await fetchAccessibleProjectIds(token);
  }
  return cache.projectIds.includes(projectId);
}

function userRoom(userId) {
  return `user:${userId}`;
}

/** Backend → realtime push for in-app notifications. */
app.post('/internal/emit', express.json({ limit: '1mb' }), (req, res) => {
  const key = req.header('X-Internal-Key') || '';
  if (!internalEmitKey || key !== internalEmitKey) {
    return res.status(401).json({ ok: false, message: 'Unauthorized' });
  }

  const eventName = String(req.body?.eventName || 'notification:new').trim();
  const deliveries = Array.isArray(req.body?.deliveries) ? req.body.deliveries : [];

  let emitted = 0;
  for (const item of deliveries) {
    const userId = String(item?.userId || '').trim();
    if (!userId || item?.data == null) continue;
    io.to(userRoom(userId)).emit(eventName, item.data);
    emitted += 1;
  }

  return res.json({ ok: true, emitted });
});

io.use((socket, next) => {
  const token = socket.handshake.auth?.token || socket.handshake.query?.token;
  const user = verifyToken(typeof token === 'string' ? token : null);
  if (!user) {
    return next(new Error('Unauthorized'));
  }
  socket.data.user = user;
  socket.data.token = token;
  socket.data.projectCache = {};
  next();
});

io.on('connection', (socket) => {
  const user = socket.data.user;
  console.log(`[realtime] connected user=${user.userId} socket=${socket.id}`);

  // Personal inbox room — always joined so notifications work outside chat rooms.
  socket.join(userRoom(user.userId));

  socket.on('join:project', async (payload, ack) => {
    try {
      const projectId = String(payload?.projectId || '').trim();
      if (!projectId) {
        ack?.({ ok: false, message: 'projectId is required' });
        return;
      }

      const allowed = await ensureProjectAccess(socket.data.token, projectId, socket.data.projectCache);
      if (!allowed) {
        ack?.({ ok: false, message: 'Forbidden' });
        return;
      }

      const room = `project:${projectId}`;
      await socket.join(room);
      ack?.({ ok: true, room });
    } catch (error) {
      console.error('[realtime] join:project failed', error);
      ack?.({ ok: false, message: 'Failed to join project room' });
    }
  });

  socket.on('leave:project', async (payload) => {
    const projectId = String(payload?.projectId || '').trim();
    if (!projectId) return;
    await socket.leave(`project:${projectId}`);
  });

  socket.on('send:message', async (payload, ack) => {
    try {
      const projectId = String(payload?.projectId || '').trim();
      const content = String(payload?.content || '').trim();
      const token =
        (typeof payload?.token === 'string' && payload.token) ||
        socket.handshake.auth?.token ||
        socket.data.token;

      if (token !== socket.data.token) {
        socket.data.token = token;
        socket.data.projectCache = {};
      }

      if (!projectId || !content) {
        ack?.({ ok: false, message: 'projectId and content are required' });
        return;
      }

      const allowed = await ensureProjectAccess(token, projectId, socket.data.projectCache);
      if (!allowed) {
        ack?.({ ok: false, message: 'Forbidden' });
        return;
      }

      const response = await axios.post(
        `${apiBaseUrl}/chat/projects/${projectId}/messages`,
        { content },
        { headers: { Authorization: `Bearer ${token}` } },
      );

      const body = response.data;
      if (!body?.isSuccess || !body.data) {
        ack?.({ ok: false, message: body?.message || 'Failed to send message' });
        return;
      }

      const message = body.data;
      io.to(`project:${projectId}`).emit('message:new', message);
      ack?.({ ok: true, message });
    } catch (error) {
      console.error('[realtime] send:message failed', error?.response?.data || error);
      ack?.({ ok: false, message: 'Failed to send message' });
    }
  });

  socket.on('broadcast:message', async (payload, ack) => {
    try {
      const projectId = String(payload?.projectId || '').trim();
      const message = payload?.message;
      if (!projectId || !message) {
        ack?.({ ok: false, message: 'projectId and message are required' });
        return;
      }

      const allowed = await ensureProjectAccess(socket.data.token, projectId, socket.data.projectCache);
      if (!allowed) {
        ack?.({ ok: false, message: 'Forbidden' });
        return;
      }

      io.to(`project:${projectId}`).emit('message:new', message);
      ack?.({ ok: true });
    } catch (error) {
      console.error('[realtime] broadcast:message failed', error);
      ack?.({ ok: false, message: 'Failed to broadcast message' });
    }
  });

  socket.on('disconnect', () => {
    console.log(`[realtime] disconnected user=${user.userId} socket=${socket.id}`);
  });
});

httpServer.listen(port, '0.0.0.0', () => {
  console.log(`[realtime] Socket.IO server listening on 0.0.0.0:${port}`);
  console.log(`[realtime] API base: ${apiBaseUrl}`);
});
