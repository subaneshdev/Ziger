import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class Error404Screen extends StatelessWidget {
  const Error404Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image (CCTV Style)
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.grey,
              BlendMode.saturation,
            ),
            child: Image.network(
              'https://images.unsplash.com/photo-1550989460-0adf9ea622e2?q=80&w=2787&auto=format&fit=crop', // Dark interior/warehouse
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.4),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          
          // 2. Scanlines / Grain Effect (Simulated with semi-transparent lines)
          IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x0A000000),
                  ],
                  stops: [0.5, 0.5],
                  tileMode: TileMode.repeated,
                ),
              ),
            ),
          ),

          // 3. UI Overlays (SafeArea)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Top Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCamText('ERROR - 404'),
                      _buildCamText('SECURITY CAM 4870'),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Center Content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => context.go('/worker/home'), // Or check role to go to correct home
                        style: TextButton.styleFrom(
                           foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'GO BACK HOME',
                          style: GoogleFonts.shareTechMono(
                            fontSize: 24,
                            letterSpacing: 4,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(blurRadius: 10, color: Colors.white, offset: Offset(0, 0)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // REC Indicator
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.red, blurRadius: 6)],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildCamText('REC'),
                        ],
                      ),
                      
                      // Timestamp
                      _buildCamText('00:04:12:58'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 4. Corner Brackets
          const Positioned(top: 20, left: 20, child: _CornerBracket(isTop: true, isLeft: true)),
          const Positioned(top: 20, right: 20, child: _CornerBracket(isTop: true, isLeft: false)),
          const Positioned(bottom: 20, left: 20, child: _CornerBracket(isTop: false, isLeft: true)),
          const Positioned(bottom: 20, right: 20, child: _CornerBracket(isTop: false, isLeft: false)),
        ],
      ),
    );
  }

  Widget _buildCamText(String text) {
    return Text(
      text,
      style: GoogleFonts.shareTechMono(
        color: Colors.white.withOpacity(0.9),
        fontSize: 16,
        letterSpacing: 1.5,
        shadows: [
            const Shadow(blurRadius: 4, color: Colors.black, offset: Offset(1, 1)),
        ],
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _CornerBracket({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    const double size = 40;
    const double thickness = 3;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Colors.white, width: thickness) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Colors.white, width: thickness) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Colors.white, width: thickness) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Colors.white, width: thickness) : BorderSide.none,
        ),
      ),
    );
  }
}
