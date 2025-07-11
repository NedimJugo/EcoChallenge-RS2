using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Services.Database.Enums;
using Microsoft.EntityFrameworkCore;

namespace EcoChallenge.Services.Database.Entities
{
    public class Location
    {
        [Key]
        public int Id { get; set; }
        [Column("name"), MaxLength(100)]
        public string? Name { get; set; }
        [Column("description")]
        public string? Description { get; set; }
        [Column("latitude"), Precision(10,8)]
        public decimal Latitude { get; set; }
        [Column("longitude"), Precision(11,8)]
        public decimal Longitude { get; set; }
        [Column("address")]
        public string? Address { get; set; }
        [Column("city"), MaxLength(100)]
        public string? City { get; set; }
        [Column("country"), MaxLength(100)]
        public string? Country { get; set; }
        [Column("postal_code"), MaxLength(20)]
        public string? PostalCode { get; set; }
        [Required, Column("location_type")]
        public LocationType LocationType { get; set; } = LocationType.Other;
        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<Request>? Requests { get; set; }
        public virtual ICollection<Event>? Events { get; set; }
        public virtual ICollection<Gallery>? Galleries { get; set; }
    }
}
