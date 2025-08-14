using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Interfeces
{
    public interface IRabbitMQService
    {
        Task PublishAsync<T>(T message, string routingKey) where T : class;
        void Dispose();
    }
}
