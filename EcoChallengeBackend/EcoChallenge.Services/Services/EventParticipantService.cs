using AutoMapper;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseServices;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Interfeces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using EcoChallenge.Models.Enums;
using Microsoft.Extensions.DependencyInjection;

public class EventParticipantService : BaseCRUDService<EventParticipantResponse, EventParticipantSearchObject, EventParticipant, EventParticipantInsertRequest, EventParticipantUpdateRequest>, IEventParticipantService
{
    private readonly IUserStatsService _userStatsService;
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<EventParticipantService> _logger;
    public EventParticipantService(EcoChallengeDbContext db, IMapper mapper, IUserStatsService userStatsService, IServiceProvider serviceProvider, ILogger<EventParticipantService> logger) : base(db, mapper)
    {
        _serviceProvider = serviceProvider;
        _userStatsService = userStatsService;
        _logger = logger;
    }

    protected override IQueryable<EventParticipant> ApplyFilter(IQueryable<EventParticipant> query, EventParticipantSearchObject s)
    {
        if (s.EventId.HasValue)
            query = query.Where(ep => ep.EventId == s.EventId.Value);

        if (s.UserId.HasValue)
            query = query.Where(ep => ep.UserId == s.UserId.Value);

        return query
            .Include(ep => ep.Event)
            .Include(ep => ep.User);
    }

    public override async Task<EventParticipantResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await _context.EventParticipants
            .Include(ep => ep.Event)
            .Include(ep => ep.User)
            .FirstOrDefaultAsync(ep => ep.Id == id, cancellationToken);

        return entity == null ? null : MapToResponse(entity);
    }

    protected override async Task BeforeInsert(EventParticipant entity, EventParticipantInsertRequest request, CancellationToken cancellationToken = default)
    {
        await UpdateParticipantCount(request.EventId, +1, cancellationToken);
        await base.BeforeInsert(entity, request, cancellationToken);
    }

    protected override async Task BeforeDelete(EventParticipant entity, CancellationToken cancellationToken = default)
    {
        await UpdateParticipantCount(entity.EventId, -1, cancellationToken);
        await base.BeforeDelete(entity, cancellationToken);
    }

    protected override async Task BeforeUpdate(EventParticipant entity, EventParticipantUpdateRequest request, CancellationToken cancellationToken = default)
    {
        var originalStatus = entity.Status;
        var oldEntity = await _context.EventParticipants.AsNoTracking().FirstOrDefaultAsync(x => x.Id == entity.Id, cancellationToken);
        if (oldEntity != null && oldEntity.EventId != entity.EventId)
        {
            await UpdateParticipantCount(oldEntity.EventId, -1, cancellationToken);
            await UpdateParticipantCount(entity.EventId, +1, cancellationToken);
        }

        await base.BeforeUpdate(entity, request, cancellationToken);

        if (request.Status.HasValue && request.Status.Value == AttendanceStatus.Attended &&
       originalStatus != AttendanceStatus.Attended)
        {
            await _userStatsService.UpdateUserEventsParticipatedAsync(entity.UserId, 1, cancellationToken);
            _ = Task.Run(async () =>
            {
                try
                {
                    using var scope = _serviceProvider.CreateScope();
                    var badgeService = scope.ServiceProvider.GetRequiredService<IBadgeManagementService>();
                    await badgeService.CheckAndAwardBadgesAsync(entity.UserId);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to check badges for user {UserId} after event attendance", entity.UserId);
                }
            });
        }
        else if (originalStatus == AttendanceStatus.Attended &&
               request.Status.HasValue && request.Status.Value != AttendanceStatus.Attended)
        {
            // Subtract from user's events participated count
            await _userStatsService.UpdateUserEventsParticipatedAsync(entity.UserId, -1, cancellationToken);
        }
    }

    private async Task UpdateParticipantCount(int eventId, int delta, CancellationToken cancellationToken)
    {
        var ev = await _context.Events.FindAsync(new object[] { eventId }, cancellationToken);
        if (ev != null)
        {
            ev.CurrentParticipants += delta;

            // Ensure we don't drop below zero or go above max (optional)
            ev.CurrentParticipants = Math.Max(0, ev.CurrentParticipants);
            ev.CurrentParticipants = Math.Min(ev.MaxParticipants, ev.CurrentParticipants);

            _context.Events.Update(ev);
        }
    }
}
