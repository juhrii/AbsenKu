import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static final Map<String, List<Map<String, dynamic>>> _membershipsCache = {};
  static final Map<String, Future<List<Map<String, dynamic>>>>
  _inFlightRequests = {};

  /// Clear cached memberships (call on logout or after joining a new org).
  static void clearCache([String? userId]) {
    if (userId == null) {
      _membershipsCache.clear();
      _inFlightRequests.clear();
    } else {
      _membershipsCache.remove(userId);
      _inFlightRequests.remove(userId);
    }
  }

  /// Synchronously return cached memberships if already fetched.
  List<Map<String, dynamic>>? getCachedMemberships(String userId) {
    return _membershipsCache[userId];
  }

  /// Get organization member with role information
  Future<Map<String, dynamic>?> getOrganizationMemberWithRole(
    String userId,
  ) async {
    try {
      // print('=== FETCHING ORGANIZATION MEMBER WITH ROLE ===');
      // print('User ID: $userId');

      final List<dynamic> responseList = await _supabase
          .from('organization_members')
          .select('''
            id,
            organization_id,
            user_id,
            employee_id,
            is_active,
            role_id,
            system_roles!organization_members_role_id_fkey (
              id,
              code,
              name,
              description,
              is_system
            )
          ''')
          .eq('user_id', userId)
          .eq('is_active', true);

      if (responseList.isEmpty) {
        // print('❌ No organization member found');
        return null;
      }

      // Return the first one as a fallback, full multi-org should use getAllOrganizationMembersWithRoles
      return responseList.first;
    } catch (e) {
      debugPrint('!!! ERROR fetching organization member: $e');
      rethrow;
    }
  }

  /// Check if user has admin role
  bool isAdmin(Map<String, dynamic>? memberData) {
    if (memberData == null) {
      // print('❌ isAdmin: memberData is null');
      return false;
    }

    if (memberData['system_roles'] == null) {
      // print('❌ isAdmin: system_roles is null');
      return false;
    }

    final roleCode = memberData['system_roles']['code'] as String?;
    // print('🔍 isAdmin check: roleCode = $roleCode');

    // Admin role codes: A001 (Admin), SA001 (Petugas)
    final result = roleCode == 'A001' || roleCode == 'SA001';
    // print('   Result: $result');
    return result;
  }

  /// Check if user has petugas role
  bool isPetugas(Map<String, dynamic>? memberData) {
    if (memberData == null) {
      // print('❌ isPetugas: memberData is null');
      return false;
    }

    if (memberData['system_roles'] == null) {
      // print('❌ isPetugas: system_roles is null');
      return false;
    }

    final roleCode = memberData['system_roles']['code'] as String?;
    // print('🔍 isPetugas check: roleCode = $roleCode');

    // Petugas role code: P001
    final result = roleCode == 'P001';
    // print('   Result: $result');
    return result;
  }

  /// Check if user has user role
  bool isUser(Map<String, dynamic>? memberData) {
    if (memberData == null) {
      // print('❌ isUser: memberData is null');
      return false;
    }

    if (memberData['system_roles'] == null) {
      // print('❌ isUser: system_roles is null');
      return false;
    }

    final roleCode = memberData['system_roles']['code'] as String?;
    // print('🔍 isUser check: roleCode = $roleCode');

    // User role code: US001
    final result = roleCode == 'US001';
    // print('   Result: $result');
    return result;
  }

  /// Check if user can access the Petugas/Admin dashboard (Admin, Petugas, Super Admin)
  bool canAccessPetugasDashboard(Map<String, dynamic>? memberData) {
    final roleCode = getRoleCode(memberData);
    return roleCode == 'P001' || roleCode == 'A001' || roleCode == 'SA001';
  }

  /// Prefer Admin/Petugas/Super Admin membership when user belongs to multiple organizations
  Map<String, dynamic> pickPreferredMembership(
    List<Map<String, dynamic>> memberships,
  ) {
    for (final m in memberships) {
      if (canAccessPetugasDashboard(m)) {
        return m;
      }
    }
    return memberships.first;
  }

  /// Get role display name
  String getRoleName(Map<String, dynamic>? memberData) {
    if (memberData == null || memberData['system_roles'] == null) {
      return 'Tidak Diketahui';
    }

    return memberData['system_roles']['name'] as String? ?? 'Tidak Diketahui';
  }

  /// Get role code
  String getRoleCode(Map<String, dynamic>? memberData) {
    if (memberData == null || memberData['system_roles'] == null) {
      return 'UNKNOWN';
    }

    return memberData['system_roles']['code'] as String? ?? 'UNKNOWN';
  }

  /// Get all active roles
  Future<List<Map<String, dynamic>>> getAllRoles() async {
    try {
      final response = await _supabase
          .from('system_roles')
          .select('id, code, name, description')
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('!!! ERROR fetching roles: $e');
      return [];
    }
  }

  /// Get ALL organization memberships for a user (cached in memory for instant switching)
  Future<List<Map<String, dynamic>>> getAllOrganizationMembersWithRoles(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _membershipsCache[userId];
      if (cached != null) {
        return cached;
      }
    }

    final inFlight = _inFlightRequests[userId];
    if (inFlight != null && !forceRefresh) {
      return inFlight;
    }

    final future = _fetchAndCacheMemberships(userId);
    _inFlightRequests[userId] = future;
    return future;
  }

  Future<List<Map<String, dynamic>>> _fetchAndCacheMemberships(
    String userId,
  ) async {
    try {
      final List<dynamic> response = await _supabase
          .from('organization_members')
          .select('''
            id,
            organization_id,
            user_id,
            employee_id,
            department_id,
            position_id,
            is_active,
            role_id,
            departments!organization_members_department_id_fkey (
              id,
              code,
              name
            ),
            positions (
              id,
              code,
              title
            ),
            organizations!organization_members_organization_id_fkey (
              id,
              name,
              logo_url,
              address,
              timezone
            ),
            system_roles!organization_members_role_id_fkey (
              id,
              code,
              name,
              description,
              is_system
            ),
            user_profiles!inner(
              id,
              display_name,
              first_name,
              last_name,
              profile_photo_url
            )
          ''')
          .eq('user_id', userId)
          .eq('is_active', true);

      final list = List<Map<String, dynamic>>.from(response);
      _membershipsCache[userId] = list;
      return list;
    } catch (e) {
      debugPrint('!!! ERROR fetching all organization memberships: $e');
      return _membershipsCache[userId] ?? <Map<String, dynamic>>[];
    } finally {
      _inFlightRequests.remove(userId);
    }
  }
}
