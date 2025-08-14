using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Subscriber.Services
{
    public interface IRabbitMQConsumerService : IDisposable
    {
        Task StartConsumingAsync(CancellationToken cancellationToken);
        Task StopConsumingAsync();
    }
}
