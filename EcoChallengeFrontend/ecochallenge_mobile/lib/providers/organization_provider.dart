
import 'package:ecochallenge_mobile/models/organization.dart';
import 'package:ecochallenge_mobile/providers/base_provider.dart';


class OrganizationProvider extends BaseProvider<Organization> {
  OrganizationProvider() : super("Organization");

  @override
  Organization fromJson(data) {
    // TODO: implement fromJson
    return Organization.fromJson(data);
  }
}
