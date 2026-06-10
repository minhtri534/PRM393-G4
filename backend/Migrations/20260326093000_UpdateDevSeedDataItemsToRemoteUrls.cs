using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataLabellingSupportSystem.Api.Migrations
{
    /// <inheritdoc />
    public partial class UpdateDevSeedDataItemsToRemoteUrls : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
    UPDATE [dbo].[DataItems]
    SET [storageProvider] = N'RemoteUrl',
        [filePath] = N'https://i.postimg.cc/nCyjGV1J/0001.jpg'
    WHERE [filePath] = N'demo/images/0001.jpg';

    UPDATE [dbo].[DataItems]
    SET [storageProvider] = N'RemoteUrl',
        [filePath] = N'https://i.postimg.cc/bs7D9YRq/0002.jpg'
    WHERE [filePath] = N'demo/images/0002.jpg';

    UPDATE [dbo].[DataItems]
    SET [storageProvider] = N'RemoteUrl',
        [filePath] = N'https://i.postimg.cc/1fknrRKR/0003.jpg'
    WHERE [filePath] = N'demo/images/0003.jpg';
");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
    UPDATE [dbo].[DataItems]
    SET [storageProvider] = N'Local',
        [filePath] = N'demo/images/0001.jpg'
    WHERE [filePath] = N'https://i.postimg.cc/nCyjGV1J/0001.jpg';

    UPDATE [dbo].[DataItems]
    SET [storageProvider] = N'Local',
        [filePath] = N'demo/images/0002.jpg'
    WHERE [filePath] = N'https://i.postimg.cc/bs7D9YRq/0002.jpg';

    UPDATE [dbo].[DataItems]
    SET [storageProvider] = N'Local',
        [filePath] = N'demo/images/0003.jpg'
    WHERE [filePath] = N'https://i.postimg.cc/1fknrRKR/0003.jpg';
");
        }
    }
}
