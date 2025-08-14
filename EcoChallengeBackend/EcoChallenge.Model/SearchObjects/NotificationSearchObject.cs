using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class NotificationSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public NotificationType? NotificationType { get; set; }
        public bool? IsRead { get; set; }
        public bool? IsPushed { get; set; }
    }
}
