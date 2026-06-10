using DataLabellingSupportSystem.Api.Utils;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.ValueGeneration;

namespace DataLabellingSupportSystem.Api.Database.ValueGenerators;

public sealed class ObjectIdValueGenerator : ValueGenerator<string>
{
    public override bool GeneratesTemporaryValues => false;

    public override string Next(EntityEntry entry) => ObjectId.NewObjectId();
}
