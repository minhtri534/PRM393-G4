using System.Buffers.Binary;

namespace DataLabellingSupportSystem.Api.Utils;

public static class ImageSizeHelper
{
    public static bool TryGetImageSize(ReadOnlySpan<byte> bytes, out int width, out int height)
    {
        width = 0;
        height = 0;

        if (bytes.Length < 24)
        {
            return false;
        }

        // PNG
        if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47)
        {
            width = BinaryPrimitives.ReadInt32BigEndian(bytes.Slice(16, 4));
            height = BinaryPrimitives.ReadInt32BigEndian(bytes.Slice(20, 4));
            return width > 0 && height > 0;
        }

        // JPEG
        if (bytes[0] == 0xFF && bytes[1] == 0xD8 && TryGetJpegSize(bytes, out width, out height))
        {
            return true;
        }

        // GIF
        if (bytes.Length >= 10 &&
            bytes[0] == (byte)'G' && bytes[1] == (byte)'I' && bytes[2] == (byte)'F')
        {
            width = bytes[6] | (bytes[7] << 8);
            height = bytes[8] | (bytes[9] << 8);
            return width > 0 && height > 0;
        }

        // BMP
        if (bytes.Length >= 26 && bytes[0] == (byte)'B' && bytes[1] == (byte)'M')
        {
            width = BinaryPrimitives.ReadInt32LittleEndian(bytes.Slice(18, 4));
            height = Math.Abs(BinaryPrimitives.ReadInt32LittleEndian(bytes.Slice(22, 4)));
            return width > 0 && height > 0;
        }

        // WEBP (RIFF....WEBP)
        if (bytes.Length >= 30 &&
            bytes[0] == (byte)'R' && bytes[1] == (byte)'I' && bytes[2] == (byte)'F' && bytes[3] == (byte)'F' &&
            bytes[8] == (byte)'W' && bytes[9] == (byte)'E' && bytes[10] == (byte)'B' && bytes[11] == (byte)'P')
        {
            return TryGetWebpSize(bytes, out width, out height);
        }

        return false;
    }

    private static bool TryGetJpegSize(ReadOnlySpan<byte> bytes, out int width, out int height)
    {
        width = 0;
        height = 0;

        var index = 2;
        while (index + 9 < bytes.Length)
        {
            if (bytes[index] != 0xFF)
            {
                index++;
                continue;
            }

            var marker = bytes[index + 1];
            index += 2;

            if (marker == 0xD9 || marker == 0xDA)
            {
                break;
            }

            if (index + 2 > bytes.Length)
            {
                break;
            }

            var segmentLength = BinaryPrimitives.ReadUInt16BigEndian(bytes.Slice(index, 2));
            if (segmentLength < 2 || index + segmentLength > bytes.Length)
            {
                break;
            }

            var isSof = marker is 0xC0 or 0xC1 or 0xC2 or 0xC3 or 0xC5 or 0xC6 or 0xC7 or 0xC9 or 0xCA or 0xCB or 0xCD or 0xCE or 0xCF;
            if (isSof && segmentLength >= 7)
            {
                height = BinaryPrimitives.ReadUInt16BigEndian(bytes.Slice(index + 3, 2));
                width = BinaryPrimitives.ReadUInt16BigEndian(bytes.Slice(index + 5, 2));
                return width > 0 && height > 0;
            }

            index += segmentLength;
        }

        return false;
    }

    private static bool TryGetWebpSize(ReadOnlySpan<byte> bytes, out int width, out int height)
    {
        width = 0;
        height = 0;

        var offset = 12;
        while (offset + 8 <= bytes.Length)
        {
            var chunkType = bytes.Slice(offset, 4);
            var chunkSize = BinaryPrimitives.ReadInt32LittleEndian(bytes.Slice(offset + 4, 4));
            offset += 8;

            if (chunkSize < 0 || offset + chunkSize > bytes.Length)
            {
                return false;
            }

            var chunkData = bytes.Slice(offset, chunkSize);

            if (chunkType[0] == (byte)'V' && chunkType[1] == (byte)'P' && chunkType[2] == (byte)'8' && chunkType[3] == (byte)' ')
            {
                if (chunkData.Length >= 10)
                {
                    width = chunkData[6] | ((chunkData[7] & 0x3F) << 8);
                    height = chunkData[8] | ((chunkData[9] & 0x3F) << 8);
                    return width > 0 && height > 0;
                }
            }
            else if (chunkType[0] == (byte)'V' && chunkType[1] == (byte)'P' && chunkType[2] == (byte)'8' && chunkType[3] == (byte)'L')
            {
                if (chunkData.Length >= 5 && chunkData[0] == 0x2F)
                {
                    var bits = BinaryPrimitives.ReadInt32LittleEndian(chunkData.Slice(1, 4));
                    width = (bits & 0x3FFF) + 1;
                    height = ((bits >> 14) & 0x3FFF) + 1;
                    return width > 0 && height > 0;
                }
            }
            else if (chunkType[0] == (byte)'V' && chunkType[1] == (byte)'P' && chunkType[2] == (byte)'8' && chunkType[3] == (byte)'X')
            {
                if (chunkData.Length >= 10)
                {
                    width = (chunkData[4] | (chunkData[5] << 8) | (chunkData[6] << 16)) + 1;
                    height = (chunkData[7] | (chunkData[8] << 8) | (chunkData[9] << 16)) + 1;
                    return width > 0 && height > 0;
                }
            }

            offset += chunkSize + (chunkSize & 1);
        }

        return false;
    }
}
