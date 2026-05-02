import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_frontend_vote/store/auth_provider.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';

// ── Wallet definition ───────────────────────────────────────────────────────

class _WalletApp {
  final String name;
  final String iconAsset;
  final String deepLink; // scheme to open the wallet
  final String description;

  const _WalletApp({
    required this.name,
    required this.iconAsset,
    required this.deepLink,
    required this.description,
  });
}

const _wallets = [
  _WalletApp(
    name: 'MetaMask',
    iconAsset: 'assets/icons/metamask.png',
    deepLink: 'metamask://wc',
    description: 'The most popular Web3 wallet',
  ),
  _WalletApp(
    name: 'Trust Wallet',
    iconAsset: 'assets/icons/trust_wallet.png',
    deepLink: 'trust://wc',
    description: 'Multi-chain crypto wallet',
  ),
  _WalletApp(
    name: 'Rainbow',
    iconAsset: 'assets/icons/rainbow.png',
    deepLink: 'rainbow://wc',
    description: 'Ethereum wallet & gateway',
  ),
  _WalletApp(
    name: 'Coinbase Wallet',
    iconAsset: 'assets/icons/coinbase_wallet.png',
    deepLink: 'cbwallet://wc',
    description: 'Your key to the open web',
  ),
  _WalletApp(
    name: 'Phantom',
    iconAsset: 'assets/icons/phantom.png',
    deepLink: 'phantom://wc',
    description: 'Multichain crypto wallet',
  ),
  _WalletApp(
    name: 'imToken',
    iconAsset: 'assets/icons/imtoken.png',
    deepLink: 'imtokenv2://wc',
    description: 'Trusted blockchain wallet',
  ),
];

// ── Screen ──────────────────────────────────────────────────────────────────

class WalletConnectScreen extends ConsumerStatefulWidget {
  const WalletConnectScreen({super.key});

  @override
  ConsumerState<WalletConnectScreen> createState() =>
      _WalletConnectScreenState();
}

class _WalletConnectScreenState extends ConsumerState<WalletConnectScreen> {
  bool _isConnecting = false;
  String? _connectingWallet;
  String? _errorMessage;

  Future<void> _connectWallet(_WalletApp wallet) async {
    setState(() {
      _isConnecting = true;
      _connectingWallet = wallet.name;
      _errorMessage = null;
    });

    try {
      // Build a challenge message for the wallet to sign.
      // In production this nonce should come from the backend (GET /auth/wallet-nonce).
      final nonce = DateTime.now().millisecondsSinceEpoch.toString();
      final message =
          'VoteSecure Sign-In\n\nClick "Sign" to authenticate.\n\nNonce: $nonce';

      // Attempt to deep-link into the wallet app.
      final uri = Uri.parse('${wallet.deepLink}?message=${Uri.encodeComponent(message)}');
      final canOpen = await canLaunchUrl(uri);

      if (!canOpen) {
        setState(() {
          _errorMessage =
              '${wallet.name} is not installed on this device. Please install it and try again.';
          _isConnecting = false;
          _connectingWallet = null;
        });
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // ── Note ──────────────────────────────────────────────────────────────
      // After the wallet signs the message and returns via deep-link callback
      // (votesecure://wallet-callback?address=0x...&signature=0x...), the router
      // will call WalletCallbackHandler which reads the query params and calls:
      //   ref.read(currentUserProvider.notifier).signInWithWallet(...)
      //
      // For now we wait for the user to return manually — the result is handled
      // in the GoRouter redirect for '/wallet-callback'.
      // ──────────────────────────────────────────────────────────────────────
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to open ${wallet.name}: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _connectingWallet = null;
        });
      }
    }
  }

  // Manual entry for advanced users
  Future<void> _pasteAndConnect() async {
    final data = await Clipboard.getData('text/plain');
    final address = data?.text?.trim() ?? '';
    if (address.isEmpty || !address.startsWith('0x')) {
      setState(() => _errorMessage = 'Invalid wallet address in clipboard.');
      return;
    }
    _showManualSignSheet(address);
  }

  void _showManualSignSheet(String address) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManualSignSheet(
        walletAddress: address,
        onSigned: (signature, message) async {
          Navigator.of(context).pop();
          await ref.read(currentUserProvider.notifier).signInWithWallet(
                walletAddress: address,
                signature: signature,
                message: message,
              );
          final state = ref.read(currentUserProvider);
          if (state.hasValue && state.valueOrNull != null && mounted) {
            context.go('/home');
          } else if (state.hasError && mounted) {
            setState(() => _errorMessage = state.error.toString());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? TColors.darkBackground : TColors.lightBackground;
    final surface = isDark ? TColors.darkSurface : TColors.lightSurface;

    // Watch for successful sign-in
    ref.listen(currentUserProvider, (_, next) {
      if (next.hasValue && next.valueOrNull != null && mounted) {
        context.go('/home');
      }
      if (next.hasError && mounted) {
        final err = next.error.toString();
        setState(() => _errorMessage =
            err.contains('E4001') || err.contains('wallet not linked')
                ? 'No verified account is linked to this wallet.\nPlease sign in with email first and link your wallet in Settings.'
                : 'Authentication failed. Please try again.');
      }
    });

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Connect Wallet',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          size: 32, color: TColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sign in with your Wallet',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? TColors.textDarkPrimary
                            : TColors.textLightPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Only verified voters with a linked wallet\ncan use this sign-in method.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: isDark
                            ? TColors.textDarkTertiary
                            : TColors.textLightTertiary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Error banner
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.red,
                            height: 1.4,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _errorMessage = null),
                        child: const Icon(Icons.close,
                            color: Colors.red, size: 16),
                      ),
                    ],
                  ),
                ),

              // Wallet grid
              Text(
                'Choose your wallet',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? TColors.textDarkSecondary
                      : TColors.textLightSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = _wallets[index];
                    final isLoading =
                        _isConnecting && _connectingWallet == wallet.name;
                    return GestureDetector(
                      onTap: _isConnecting ? null : () => _connectWallet(wallet),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? TColors.darkBorder
                                : TColors.lightBorder,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isLoading)
                              const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: TColors.primary),
                              )
                            else
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  wallet.iconAsset,
                                  width: 44,
                                  height: 44,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: TColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                        Icons.account_balance_wallet_outlined,
                                        size: 24,
                                        color: TColors.primary),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              wallet.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? TColors.textDarkPrimary
                                    : TColors.textLightPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              // Manual / paste address option
              GestureDetector(
                onTap: _pasteAndConnect,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(TSizes.radiusSm),
                    border: Border.all(
                      color: isDark ? TColors.darkBorder : TColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.content_paste_rounded,
                          size: 18,
                          color: isDark
                              ? TColors.textDarkSecondary
                              : TColors.textLightSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'Paste wallet address',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? TColors.textDarkSecondary
                              : TColors.textLightSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Manual sign bottom sheet ─────────────────────────────────────────────────

class _ManualSignSheet extends StatefulWidget {
  final String walletAddress;
  final void Function(String signature, String message) onSigned;

  const _ManualSignSheet({
    required this.walletAddress,
    required this.onSigned,
  });

  @override
  State<_ManualSignSheet> createState() => _ManualSignSheetState();
}

class _ManualSignSheetState extends State<_ManualSignSheet> {
  final _signatureCtrl = TextEditingController();
  final _message =
      'VoteSecure Sign-In\n\nNonce: ${DateTime.now().millisecondsSinceEpoch}';

  @override
  void dispose() {
    _signatureCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          const Text('Sign the message',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text('Wallet: ${widget.walletAddress}',
              style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(_message,
                style: const TextStyle(
                    fontFamily: 'monospace', fontSize: 12, height: 1.4)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _signatureCtrl,
            decoration: const InputDecoration(
              labelText: 'Paste signature (0x...)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                final sig = _signatureCtrl.text.trim();
                if (sig.isEmpty || !sig.startsWith('0x')) return;
                widget.onSigned(sig, _message);
              },
              child: const Text('Verify Signature',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

