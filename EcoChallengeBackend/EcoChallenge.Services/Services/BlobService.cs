using Azure.Storage.Blobs;
using EcoChallenge.Services.Interfeces;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Services
{
    public class BlobService : IBlobService
    {

        private readonly BlobServiceClient _blobServiceClient;
        private readonly string? _containerName;
        public BlobService(IConfiguration config)
        {
            _blobServiceClient = new BlobServiceClient(config["AzureBlobStorage:ConnectionString"]);
            _containerName = config["AzureBlobStorage:Container name"]!;
        }

        public async Task<string> UploadFileAsync(IFormFile file)
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
            await containerClient.CreateIfNotExistsAsync();

            var blobClient = containerClient.GetBlobClient(Guid.NewGuid() + Path.GetExtension(file.FileName));
            using (var stream = file.OpenReadStream())
            {
                await blobClient.UploadAsync(stream, overwrite: true);
            }

            return blobClient.Uri.ToString();
        }
    }

}
