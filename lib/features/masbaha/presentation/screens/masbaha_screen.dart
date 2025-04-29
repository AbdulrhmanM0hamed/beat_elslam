import 'package:beat_elslam/core/utils/constant/font_manger.dart';
import 'package:beat_elslam/core/utils/constant/styles_manger.dart';
import 'package:beat_elslam/core/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/masbaha_cubit.dart';
import '../cubit/masbaha_state.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({Key? key, required String title})
      : super(
          key: key,
          title: Text(
            title,
            style: getBoldStyle(
              fontFamily: FontConstant.cairo,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
        );
}

class MasbahaScreen extends StatelessWidget {
  const MasbahaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MasbahaCubit(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'المسبحة الإلكترونية'),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: BlocBuilder<MasbahaCubit, MasbahaState>(
            builder: (context, state) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Content section (counter and saved counts)
                  Column(
                    children: [
                      // Counter display
                      const SizedBox(height: 40),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${state.counter}',
                                style: getBoldStyle(
                                  fontFamily: FontConstant.cairo,
                                  fontSize: 90,
                                  color: AppColors.primary,
                                )
                              ),
                              const SizedBox(height: 30),
             
                            ],
                          ),
                        ),
                      ),
                      
                      // Action buttons at bottom
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      onTap: () => context.read<MasbahaCubit>().reset(),
                                      label: 'تصفير',
                                      icon: Icons.refresh,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildActionButton(
                                      onTap: () => context.read<MasbahaCubit>().setToOne(),
                                      label: 'البدء',
                                      icon: Icons.looks_one,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                              
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Circular Tasbih button
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.3,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () => context.read<MasbahaCubit>().increment(),
                        splashColor: Colors.white.withOpacity(0.3),
                        highlightColor: Colors.white.withOpacity(0.1),
                        child: Ink(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'تسبيح',
                              style: getSemiBoldStyle(
                                fontFamily: FontConstant.cairo,
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.3),
        highlightColor: color.withOpacity(0.1),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: getSemiBoldStyle(
                  fontFamily: FontConstant.cairo,
                  color: color,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

} 