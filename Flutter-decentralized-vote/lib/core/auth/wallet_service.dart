import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:flutter_frontend_vote/core/services/storage_service.dart';
import 'package:flutter_frontend_vote/core/config/environment.dart';

/// WalletService — wraps Reown AppKit (WalletConnect v2).
///
/// Responsibilities:
///   • Initialise the AppKit modal once per session
///   • Auto-detect installed wallets on the user's device via the
///     WalletConnect Cloud registry — no hard-coded wallet list
///   • Open the wallet-picker modal
///   • Build a SIWE-style nonce challenge and request personal_sign
///   • Persist / clear the connected session
class WalletService {
  WalletService._();
  static final WalletService instance = WalletService._();

  ReownAppKitModal? _modal;
  bool _initialized = false;

  // ── Getters ────────────────────────────────────────────────────────────────

  /// True once a WalletConnect session is active.
  bool get isConnected => _modal?.isConnected ?? false;

  /// Checksummed EVM address of the connected wallet, or null.
  String? get address => _modal?.session?.getAddress('eip155');

  /// The underlying AppKit modal (for advanced usage / listening to events).
  ReownAppKitModal? get modal => _modal;

  // ── Init ───────────────────────────────────────────────────────────────────

  /// Call once — typically in [initDependencies] or the WalletConnectScreen.
  Future<void> init(BuildContext context) async {
    if (_initialized) return;

    _modal = ReownAppKitModal(
      context: context,
      projectId: Environment.walletConnectProjectId,
      metadata: const PairingMetadata(
        name: 'VoteSecure',
        description: 'Decentralized Civic Voting Platform',
        url: 'https://votesecure.app',
        icons: ['https://votesecure.app/icon.png'],
        redirect: Redirect(
          native: 'votesecure://',
          universal: 'https://votesecure.app/wallet',
        ),
      ),
    );

    await _modal!.init();
    _initialized = true;
    debugPrint('[WalletService] AppKit initialised');
  }

  // ── Connect flow ───────────────────────────────────────────────────────────

  /// Opens the AppKit wallet-picker modal.
  ///
  /// AppKit automatically:
  ///   • Fetches the WalletConnect Cloud registry (~400 wallets)
  ///   • Detects which wallets are installed on the device
  ///   • Shows installed wallets first, then all others
  ///   • Handles QR code, deep-link, and in-app browser flows
  Future<void> openModal() async {
    if (_modal == null) throw StateError('WalletService not initialised');
    await _modal!.openModalView();
  }

  // ── SIWE challenge ────────────────────────────────────────────────────────

  /// Request a personal_sign on a SIWE-style nonce message.
  ///
  /// Returns `(message, signature)` to be verified by the backend.
  Future<({String message, String signature})> requestSignature({
    String? nonce,
    int chainId = 1,
  }) async {
    if (_modal == null || !isConnected) {
      throw StateError('No active wallet session');
    }

    final addr = address!;
    final resolvedNonce = nonce ?? _generateNonce();
    final issuedAt = DateTime.now().toUtc().toIso8601String();

    final message = 'VoteSecure wants you to sign in with your Ethereum account:\n'
        '$addr\n\n'
        'By signing you confirm you are the owner of this wallet.\n\n'
        'URI: https://votesecure.app\n'
        'Version: 1\n'
        'Chain ID: $chainId\n'
        'Nonce: $resolvedNonce\n'
        'Issued At: $issuedAt';

    final hexMessage =
        '0x${utf8.encode(message).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

    final signature = await _modal!.request(
      topic: _modal!.session!.topic,
      chainId: 'eip155:$chainId',
      request: SessionRequestParams(
        method: 'personal_sign',
        params: [hexMessage, addr],
      ),
    ) as String;

    return (message: message, signature: signature);
  }

  // ── Disconnect ─────────────────────────────────────────────────────────────

  Future<void> disconnect() async {
    if (_modal == null) return;
    try {
      await _modal!.disconnect();
    } catch (e) {
      debugPrint('[WalletService] disconnect error: $e');
    }
    await SecureStorageService.clearAll();
    debugPrint('[WalletService] Disconnected');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _generateNonce([int length = 16]) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random.secure();
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
