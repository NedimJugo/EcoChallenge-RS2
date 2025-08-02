
import 'package:ecochallenge_mobile/models/donation.dart';
import 'package:ecochallenge_mobile/pages/search_result.dart';
import 'package:ecochallenge_mobile/providers/base_provider.dart';

class DonationProvider extends BaseProvider<DonationResponse> {
  DonationProvider() : super("Donation");

  @override
  DonationResponse fromJson(data) {
    return DonationResponse.fromJson(data);
  }

  // Get donations with search filters
  Future<SearchResult<DonationResponse>> getDonations({DonationSearchObject? searchObject}) async {
    try {
      final result = await get(filter: searchObject?.toJson());
      return result;
    } catch (e) {
      throw Exception("Failed to get donations: $e");
    }
  }

  // Insert new donation
  Future<DonationResponse> insertDonation(DonationInsertRequest request) async {
    try {
      return await insert(request.toJson());
    } catch (e) {
      throw Exception("Failed to insert donation: $e");
    }
  }

  // Update existing donation
  Future<DonationResponse> updateDonation(DonationUpdateRequest request) async {
    try {
      return await update(request.id, request.toJson());
    } catch (e) {
      throw Exception("Failed to update donation: $e");
    }
  }


  // Process donation
  Future<DonationResponse> processDonation(int id) async {
    try {
      final updateRequest = DonationUpdateRequest(
        id: id,
        processedAt: DateTime.now(),
      );
      return await updateDonation(updateRequest);
    } catch (e) {
      throw Exception("Failed to process donation: $e");
    }
  }
}
