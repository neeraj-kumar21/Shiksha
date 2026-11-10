import 'dart:ui';
import 'dart:math' as math ;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const ShikshaApp());

const navy = Color(0xFFEEF1FF);
const blue = Color(0xFF3B5BFF);
const violet = Color(0xFF7C4DFF);
const cyan = Color(0xFF56D9F5);
const bg = Color(0xFF0B0F1E);
const grey = Color(0xFF9AA6D8);
const green = Color(0xFF1FB57A);
const orange = Color(0xFFFF9C3A);
const grad = LinearGradient(colors: [blue, violet]);

// ---------- APP SETTINGS ----------

final ValueNotifier<bool> appDarkMode = ValueNotifier<bool>(true);

final ValueNotifier<bool> appSoundEffects = ValueNotifier<bool>(true);

void playAppSound() {
  if (appSoundEffects.value) {
    SystemSound.play(SystemSoundType.click);
  }
}


class ShikshaApp extends StatelessWidget {
  const ShikshaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shiksha',

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F7FF),
            colorScheme: ColorScheme.fromSeed(
              seedColor: blue,
              brightness: Brightness.light,
            ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: bg,
            colorScheme: ColorScheme.fromSeed(
              seedColor: blue,
              brightness: Brightness.dark,
            ),
          ),

          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          home: const SplashScreen(),
        );
      },
    );
  }
}

// ---------- REUSABLE WIDGETS ----------

/// Image from assets/images/. If file is missing, shows gradient + icon.
class Pic extends StatelessWidget {
  final String? asset;
  final IconData icon;
  final List<Color> colors;
  final double? w, h;
  final double r;
  const Pic({
    super.key,
    this.asset,
    required this.icon,
    this.colors = const [blue, violet],
    this.w,
    this.h,
    this.r = 16,
  });
  @override
  Widget build(BuildContext context) {
    final fb = Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
      child: Icon(icon, color: Colors.white, size: (h ?? 60) * 0.45),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: SizedBox(
        width: w,
        height: h,
        child: asset == null
            ? fb
            : Image.asset(asset!, fit: BoxFit.cover, errorBuilder: (_, _, _) => fb),
      ),
    );
  }
}

class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  const Glass({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.color});
  @override
  Widget build(BuildContext context) => Transform(
        alignment: Alignment.center,
        // SPATIAL: slight 3D tilt so cards float toward the viewer
        transform: Matrix4.identity()..setEntry(3, 2, 0.0008)..rotateX(0.03),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: blue.withValues(alpha: 0.28), blurRadius: 26),
              BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 34, offset: const Offset(0, 16)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: double.infinity,
                padding: padding,
                decoration: BoxDecoration(
                  color: color,
                  gradient: color == null
                      ? LinearGradient(colors: [Colors.white.withValues(alpha: 0.11), Colors.white.withValues(alpha: 0.05)])
                      : null,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: child,
              ),
            ),
          ),
        ),
      );
}

class GradButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const GradButton(this.text, {super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: grad,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: blue.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ]),
        ),
      );
}

class ChipRow extends StatefulWidget {
  final List<String> labels;
  const ChipRow(this.labels, {super.key});
  @override
  State<ChipRow> createState() => _ChipRowState();
}

class _ChipRowState extends State<ChipRow> {
  int sel = 0;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (int i = 0; i < widget.labels.length; i++)
            GestureDetector(
              onTap: () => setState(() => sel = i),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  gradient: sel == i ? grad : null,
                  color: sel == i ? null : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(widget.labels[i],
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: sel == i ? Colors.white : navy)),
              ),
            ),
        ]),
      );
}

class Header extends StatelessWidget {
  final String title, sub;
  final bool back;
  const Header(this.title, this.sub, {super.key, this.back = true});
  @override
  Widget build(BuildContext context) => Row(children: [
        if (back)
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: navy),
          ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: navy)),
            Text(sub, style: const TextStyle(fontSize: 12, color: grey)),
          ]),
        ),
      ]);
}

Widget pageBody(List<Widget> children) => SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 24), children: children),
    );

const gap = SizedBox(height: 16);

void push(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));

Future<void> confirmLogout(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF111735),
      title: const Text('Logout?', style: TextStyle(color: navy)),
      content: const Text('Are you sure you want to logout?', style: TextStyle(color: grey)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Logout', style: TextStyle(color: Color(0xFFE5484D))),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (route) => false,
    );
  }
}

void showInfoSheet(BuildContext context, String title, List<String> lines) => showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111735),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: navy)),
          const SizedBox(height: 12),
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(l, style: const TextStyle(color: grey, height: 1.4)),
            ),
        ]),
      ),
    );

final profileName = ValueNotifier<String>('Neeraj Kumar');
final profileClass = ValueNotifier<String>('Class 10');

Future<void> editProfile(BuildContext context) async {
  var name = profileName.value;
  var cls = profileClass.value;
  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (_, setLocal) => AlertDialog(
        backgroundColor: const Color(0xFF111735),
        title: const Text('Edit Profile', style: TextStyle(color: navy)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextFormField(
            initialValue: name,
            maxLength: 30,
            style: const TextStyle(color: navy),
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (s) => setLocal(() => name = s),
          ),
          const SizedBox(height: 12),
          const Text('Class', style: TextStyle(color: grey, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final c in ['Class 9', 'Class 10', 'Class 11', 'Class 12'])
              ChoiceChip(
                label: Text(c),
                selected: cls == c,
                onSelected: (_) => setLocal(() => cls = c),
              ),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: name.trim().isEmpty ? null : () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  if (saved == true) {
    profileName.value = name.trim();
    profileClass.value = cls;
  }
}

// ---------- 1. LANDING ----------

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(fit: StackFit.expand, children: [
          // YOUR LOGO ARTWORK -> assets/images/logo_splash.png
          Image.asset('assets/images/logo_splash.png', fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                    decoration: const BoxDecoration(
                        gradient: RadialGradient(center: Alignment.topCenter, radius: 1.3, colors: [Color(0xFF2B3A8F), bg])),
                    child: const Center(child: Text('Shiksha', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white))),
                  )),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 0, 26, 28),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                GradButton('Get Started',
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Shell()))),
                const SizedBox(height: 14),
                const Text.rich(TextSpan(
                    text: 'Already have an account?  ',
                    style: TextStyle(fontSize: 12, color: Color(0xFF14264F)),
                    children: [TextSpan(text: 'Login', style: TextStyle(color: blue, fontWeight: FontWeight.w700))])),
              ]),
            ),
          ),
        ]),
      );
}

// ---------- SHELL (BOTTOM NAV) ----------

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  void go(int n) => setState(() => i = n);
  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(go: go),
      const PracticeScreen(),
      const ProgressScreen(),
      const CareerScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: RadialGradient(center: Alignment.topCenter, radius: 1.3, colors: [Color(0xFF2B3A8F), bg])),
        child: Stack(children: [
          Positioned(top: -60, right: -50, child: _orb(violet, 240)),
          Positioned(bottom: 90, left: -80, child: _orb(cyan, 220)),
          screens[i],
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: go,
        backgroundColor: const Color(0xFF111735),
        indicatorColor: blue.withValues(alpha: 0.35),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_rounded), label: 'Tests'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart_rounded), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.work_outline_rounded), selectedIcon: Icon(Icons.work_rounded), label: 'Career'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'More'),
        ],
      ),
    );
  }
}

// ---------- 2. HOME ----------

class HomeScreen extends StatelessWidget {
  final void Function(int) go;
  const HomeScreen({super.key, required this.go});
  @override
  Widget build(BuildContext context) => pageBody([
        Row(children: [
          const Pic(asset: 'assets/images/logo_icon.png', icon: Icons.school_rounded, w: 44, h: 44, r: 14),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hello, Neeraj 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: navy)),
              Text("Keep going! You're doing great!", style: TextStyle(fontSize: 12, color: grey)),
            ]),
          ),
          const Icon(Icons.notifications_none_rounded, color: navy),
          const SizedBox(width: 10),
          GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => go(4) , child:  Pic(asset: 'assets/images/avatar.png',icon: Icons.person,w: 38,h: 38,r: 19,),),
        ]),
        gap,
        Glass(
          child: Row(children: [
            const Pic(icon: Icons.track_changes_rounded, colors: [Color(0xFF9DB5FF), blue], w: 54, h: 54, r: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Daily Goal', style: TextStyle(fontWeight: FontWeight.w800, color: navy)),
                const Text('Complete 20 questions today', style: TextStyle(fontSize: 11, color: grey)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                      value: 0.4, minHeight: 6, backgroundColor: Color(0xFFE4E9F5), valueColor: AlwaysStoppedAnimation(blue)),
                ),
              ]),
            ),
            const SizedBox(width: 10),
            const Text('8/20', style: TextStyle(fontWeight: FontWeight.w800, color: blue)),
          ]),
        ),
        gap,
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.05,
          children: [
            ToolCard('AI Study Assistant', 'Ask anything,\nGet instant answers', Icons.smart_toy_rounded,
                const [Color(0xFFD6F4FF), Color(0xFFB9D9FF)], blue, () => push(context, const AssistantScreen())),
            ToolCard('Practice Tests', 'MCQ • Short • Long\nAnswers', Icons.fact_check_rounded,
                const [Color(0xFFFFE0F0), Color(0xFFE5D2FF)], violet, () => go(1)),
            ToolCard('Career Guidance', 'Explore your future\nwith AI', Icons.explore_rounded,
                const [Color(0xFFD5F7E4), Color(0xFFBFEFD6)], green, () => go(3)),
            ToolCard('Study Resources', 'Notes • Videos • PDFs', Icons.menu_book_rounded,
                const [Color(0xFFFFEBC9), Color(0xFFFFD9B8)], orange, () => push(context, const ResourcesScreen())),
          ],
        ),
        gap,
        const Text("Today's Highlights", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: navy)),
        const SizedBox(height: 10),
        Glass(
          child: Row(children: [
            const Pic(icon: Icons.functions_rounded, colors: [Color(0xFF8E9BFF), violet], w: 42, h: 42, r: 13),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Mathematics', style: TextStyle(fontWeight: FontWeight.w800, color: navy)),
                Text('Algebra • Practice Test', style: TextStyle(fontSize: 11, color: grey)),
              ]),
            ),
            GestureDetector(
              onTap: () => push(context, const QuizScreen()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                decoration: BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(18)),
                child: const Text('Start', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ]);
}

class ToolCard extends StatelessWidget {
  final String title, sub;
  final IconData icon;
  final List<Color> colors;
  final Color accent;
  final VoidCallback onTap;
  const ToolCard(this.title, this.sub, this.icon, this.colors, this.accent, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [accent.withValues(alpha: 0.32), Colors.white.withValues(alpha: 0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 24)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Colors.white),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: navy)),
            const SizedBox(height: 3),
            Row(children: [
              Expanded(child: Text(sub, style: const TextStyle(fontSize: 10, color: grey))),
              Icon(Icons.arrow_forward_rounded, size: 16, color: accent),
            ]),
          ]),
        ),
      );
}

// ---------- 3. AI STUDY ASSISTANT ----------

class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1B2766), bg]),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                const Header('AI Study Assistant', 'Ask your doubts, get instant help'),
                const SizedBox(height: 20),
                const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Pic(asset: 'assets/images/robot.png', icon: Icons.smart_toy_rounded, w: 110, h: 110, r: 30),
                  SizedBox(width: 10),
                  Expanded(
                    child: Glass(
                      child: Text("Hi Neeraj! 👋\nAsk me anything about your studies. I'm here to help.",
                          style: TextStyle(color: navy, height: 1.4, fontSize: 13)),
                    ),
                  ),
                ]),
                const Spacer(),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(spacing: 10, runSpacing: 10, children: [
                    Sugg(Icons.lightbulb_outline, 'Solve this question'),
                    Sugg(Icons.chat_bubble_outline, 'Explain in simple words'),
                    Sugg(Icons.edit_outlined, 'Give example'),
                    Sugg(Icons.star_border_rounded, 'Important topics'),
                  ]),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
                  child: Row(children: [
                    const Expanded(
                      child: TextField(decoration: InputDecoration(hintText: 'Type your question...', border: InputBorder.none)),
                    ),
                    const Icon(Icons.mic_none_rounded, color: grey),
                    const SizedBox(width: 6),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(gradient: grad, shape: BoxShape.circle),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );
}

class Sugg extends StatelessWidget {
  final IconData icon;
  final String text;
  const Sugg(this.icon, this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: blue),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: navy)),
        ]),
      );
}

// ---------- 4. PRACTICE TESTS ----------

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});
  @override
  Widget build(BuildContext context) => pageBody([
        const Header('Practice Tests', 'Test your knowledge & improve', back: false),
        gap,
        const ChipRow(['MCQ', 'Short Answer', 'Long Answer']),
        gap,
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: const [
            SubjectTile('Mathematics', '10 Tests • 15 Mins', Icons.calculate_rounded, blue, Color(0xFFE6ECFF)),
            SubjectTile('Physics', '8 Tests • 15 Mins', Icons.bolt_rounded, violet, Color(0xFFEFE6FF)),
            SubjectTile('Chemistry', '7 Tests • 15 Mins', Icons.science_rounded, orange, Color(0xFFFFEDD9)),
            SubjectTile('Biology', '6 Tests • 15 Mins', Icons.eco_rounded, green, Color(0xFFDDF6E8)),
          ],
        ),
        gap,
        GradButton('Start Test', onTap: () => push(context, const QuizScreen())),
        gap,
        const Row(children: [
          Expanded(child: Text('Recent Tests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: navy))),
          Text('View All', style: TextStyle(fontSize: 12, color: blue)),
        ]),
        const SizedBox(height: 10),
        const ScoreRow('Algebra - MCQ', '8/10  •  12 Apr 2025', '80%', green),
        const SizedBox(height: 10),
        const ScoreRow('Trigonometry - MCQ', '7/10  •  10 Apr 2025', '70%', orange),
        const SizedBox(height: 10),
        const ScoreRow('Geometry - MCQ', '9/10  •  8 Apr 2025', '90%', green),
      ]);
}

class SubjectTile extends StatelessWidget {
  final String t, s;
  final IconData i;
  final Color c, bgc;
  const SubjectTile(this.t, this.s, this.i, this.c, this.bgc, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 22)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12)),
            child: Icon(i, color: Colors.white, size: 22),
          ),
          const Spacer(),
          Text(t, style: const TextStyle(fontWeight: FontWeight.w800, color: navy, fontSize: 13)),
          Text(s, style: const TextStyle(fontSize: 10, color: grey)),
        ]),
      );
}

class ScoreRow extends StatelessWidget {
  final String t, s, p;
  final Color c;
  const ScoreRow(this.t, this.s, this.p, this.c, {super.key});
  @override
  Widget build(BuildContext context) => Glass(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Pic(icon: Icons.description_rounded, colors: [c, c.withValues(alpha: 0.7)], w: 36, h: 36, r: 11),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: const TextStyle(fontWeight: FontWeight.w700, color: navy, fontSize: 13)),
              Text(s, style: const TextStyle(fontSize: 10, color: grey)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Text(p, style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ]),
      );
}

// ---------- 5. PROFILE (More tab) ----------

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => pageBody([
        Row(children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(gradient: grad, shape: BoxShape.circle),
            child: const Pic(asset: 'assets/images/avatar.png', icon: Icons.person, w: 76, h: 76, r: 38),
          ),
          const SizedBox(width: 14),
           Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ValueListenableBuilder<String>(
                valueListenable: profileName,
                builder: (_, v, _) => Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: navy)),
              ),
              ValueListenableBuilder<String>(
                valueListenable: profileClass,
                builder: (_, v, _) => Text('$v  •  ID: SHK12345', style: const TextStyle(fontSize: 11, color: grey)),
              ),
              const SizedBox(height: 8),
              const Row(children: [
                Tag('Free Plan', blue, Color(0xFFE4E9FF)),
                SizedBox(width: 8),
                Tag('Upgrade', Color(0xFFD98A00), Color(0xFFFFF0CC)),
              ]),
            ]),
          ),
        ]),
        gap,
        const Row(children: [
          Expanded(child: StatBox('8/20', 'Daily Questions')),
          SizedBox(width: 10),
          Expanded(child: StatBox('12', 'Day Streak')),
          SizedBox(width: 10),
          Expanded(child: StatBox('68%', 'Accuracy')),
        ]),
        gap,
        Container(
          height: 120,
          padding: const EdgeInsets.all(18),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0E1F5B), Color(0xFF2B4AD9)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Your Learning Journey', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text('Small steps every day\nlead to big dreams.', style: TextStyle(color: Color(0xFFDCE5FF), fontSize: 12)),
          ]),
        ),
        gap,
        Glass(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: [
            MenuRow(Icons.edit_outlined, 'Edit Profile', onTap: () => editProfile(context)),
            MenuRow(
              Icons.emoji_events_outlined,
              'My Achievements',
              onTap: () => showInfoSheet(context, 'My Achievements', [
                '🔥 12-day study streak',
                '✅ 12 tests completed',
                '🎯 68% accuracy',
                'Yeh abhi sample data hai. Asli data login aur database ke baad aayega.',
              ]),
            ),
            MenuRow(Icons.settings_outlined,'Settings',onTap: () {Navigator.push(context,MaterialPageRoute(  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
            MenuRow(
              Icons.help_outline_rounded,
              'Help & Support',
              onTap: () => showInfoSheet(context, 'Help & Support', [
                'Doubt ho to AI Study Assistant use kijiye (Home screen).',
                'Practice ke liye Tests tab mein MCQ quiz kholiye.',
                'Career ke liye Career tab dekhiye.',
                'Support contact details backend ke saath jodi jaayengi.',
              ]),
            ),
            MenuRow(
              Icons.info_outline_rounded,
              'About Shiksha',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Shiksha',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Learn • Grow • Build Your Future',
              ),
            ),
          ]),
        ),
        gap,
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => confirmLogout(context),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFFFEEF0), borderRadius: BorderRadius.circular(25)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.logout_rounded, color: Color(0xFFE5484D), size: 18),
              SizedBox(width: 8),
              Text('Logout', style: TextStyle(color: Color(0xFFE5484D), fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ]);
}
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool darkMode = true;
  bool soundEffects = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Receive study reminders'),
            value: notifications,
            onChanged: (value) {
              setState(() => notifications = value);
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark appearance'),
            value: darkMode,
            onChanged: (value) {
              setState(() => darkMode = value);
            },
          ),
          SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Enable app sounds'),
            value: soundEffects,
            onChanged: (value) {
              setState(() => soundEffects = value);
            },
          ),
        ],
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final String t;
  final Color c, b;
  const Tag(this.t, this.c, this.b, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: b, borderRadius: BorderRadius.circular(12)),
        child: Text(t, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

class StatBox extends StatelessWidget {
  final String v, l;
  const StatBox(this.v, this.l, {super.key});
  @override
  Widget build(BuildContext context) => Glass(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(children: [
          Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: navy)),
          Text(l, style: const TextStyle(fontSize: 10, color: grey)),
        ]),
      );
}

class MenuRow extends StatelessWidget {
  final IconData i;
  final String t;
  final VoidCallback? onTap;
  const MenuRow(this.i, this.t, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        onTap: onTap,
        leading: Icon(i, color: blue, size: 20),
        title: Text(t, style: const TextStyle(fontSize: 13, color: navy, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, color: grey),
      );
}

// ---------- 6. CAREER GUIDANCE ----------

class CareerScreen extends StatelessWidget {
  const CareerScreen({super.key});
  @override
  Widget build(BuildContext context) => pageBody([
        const Header('Career Guidance', 'Discover your future, explore careers', back: false),
        gap,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Search careers, skills, or interests...',
              hintStyle: TextStyle(fontSize: 12),
              border: InputBorder.none,
              icon: Icon(Icons.search_rounded, color: grey),
            ),
          ),
        ),
        gap,
        const ChipRow(['All', 'Engineering', 'Medical', 'Commerce']),
        gap,
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: const [
            CareerCard('Software Engineer', 'High Growth', 'assets/images/software.png', Icons.laptop_mac_rounded, blue),
            CareerCard('Doctor', 'High Demand', 'assets/images/doctor.png', Icons.medical_services_rounded, green),
            CareerCard('Data Scientist', 'Future Ready', 'assets/images/data.png', Icons.psychology_rounded, violet),
            CareerCard('Civil Engineer', 'Good Scope', 'assets/images/civil.png', Icons.engineering_rounded, orange),
          ],
        ),
        gap,
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF4B3BE0), Color(0xFF9B6BFF)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(children: [
            const Pic(asset: 'assets/images/robot.png', icon: Icons.smart_toy_rounded, w: 56, h: 56, r: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Not sure? Let AI suggest', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                Text('careers based on your interests.', style: TextStyle(color: Color(0xFFE6E0FF), fontSize: 11)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(16)),
              child: const Text('Try AI Guidance', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      ]);
}

class CareerCard extends StatelessWidget {
  final String t, tag, img;
  final IconData i;
  final Color c;
  const CareerCard(this.t, this.tag, this.img, this.i, this.c, {super.key});
  @override
  Widget build(BuildContext context) => Glass(
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Pic(asset: img, icon: i, colors: [c, c.withValues(alpha: 0.6)], w: double.infinity, h: 90, r: 14),
          ),
          const SizedBox(height: 8),
          Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: navy)),
          Row(children: [
            Icon(Icons.circle, size: 8, color: c),
            const SizedBox(width: 4),
            Text(tag, style: TextStyle(fontSize: 10, color: c, fontWeight: FontWeight.w600)),
          ]),
        ]),
      );
}

// ---------- 7. MY PROGRESS ----------

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});
  @override
  Widget build(BuildContext context) => pageBody([
        const Header('My Progress', 'Track your learning journey', back: false),
        gap,
        Glass(
          child: Row(children: [
            const SizedBox(
              height: 110,
              width: 110,
              child: Stack(fit: StackFit.expand, children: [
                CircularProgressIndicator(
                  value: 0.72,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Color(0xFFE4E9F5),
                  valueColor: AlwaysStoppedAnimation(violet),
                ),
                Center(child: Text('72%', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: navy))),
              ]),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Overall Performance', style: TextStyle(fontSize: 12, color: grey)),
                SizedBox(height: 6),
                Text('Good progress!', style: TextStyle(color: green, fontWeight: FontWeight.w800)),
                Text('Keep it up!', style: TextStyle(color: blue, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
        ),
        gap,
        const Row(children: [
          Expanded(child: StatBox('12', 'Tests Taken')),
          SizedBox(width: 10),
          Expanded(child: StatBox('86', 'Correct Answers')),
          SizedBox(width: 10),
          Expanded(child: StatBox('18h 24m', 'Study Time')),
        ]),
        gap,
        const Text('Subject Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: navy)),
        const SizedBox(height: 10),
        const Glass(
          child: Column(children: [
            ProgressRow('Mathematics', 0.78, green),
            ProgressRow('Science', 0.71, orange),
            ProgressRow('English', 0.68, blue),
            ProgressRow('Social Science', 0.62, violet),
          ]),
        ),
        gap,
        Glass(
          color: const Color(0x3314B890),
          child: Row(children: [
            const Pic(icon: Icons.insights_rounded, colors: [green, cyan], w: 52, h: 52, r: 16),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Daily Report Ready', style: TextStyle(fontWeight: FontWeight.w800, color: navy)),
                Text('Check your complete progress', style: TextStyle(fontSize: 11, color: grey)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(16)),
              child: const Text('View Report', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      ]);
}

class ProgressRow extends StatelessWidget {
  final String s;
  final double v;
  final Color c;
  const ProgressRow(this.s, this.v, this.c, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(children: [
          Row(children: [
            Expanded(child: Text(s, style: const TextStyle(fontSize: 12, color: navy, fontWeight: FontWeight.w600))),
            Text('${(v * 100).round()}%', style: const TextStyle(fontSize: 12, color: navy)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
                value: v, minHeight: 6, backgroundColor: const Color(0xFFE4E9F5), valueColor: AlwaysStoppedAnimation(c)),
          ),
        ]),
      );
}

// ---------- 8. STUDY RESOURCES ----------

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: pageBody([
          const Header('Study Resources', 'Notes, Videos, PDFs & more'),
          gap,
          const ChipRow(['All', 'Notes', 'Videos', 'PDFs']),
          gap,
          const ResRow('Mathematics', 'Class 9-12  •  PDF', '12 Files', Icons.picture_as_pdf_rounded, blue),
          const ResRow('Physics', 'Class 9-12  •  Video', '8 Videos', Icons.play_circle_rounded, Color(0xFFE5484D)),
          const ResRow('Chemistry', 'Class 9-12  •  Notes', '10 Files', Icons.description_rounded, green),
          const ResRow('Biology', 'Class 9-12  •  PDF', '9 Files', Icons.biotech_rounded, green),
          const ResRow('English', 'Class 9-12  •  Video', '7 Videos', Icons.menu_book_rounded, Color(0xFFE5484D)),
          const ResRow('History', 'Class 9-12  •  Notes', '6 Files', Icons.account_balance_rounded, orange),
        ]),
      );
}

class ResRow extends StatelessWidget {
  final String t, s, n;
  final IconData i;
  final Color c;
  const ResRow(this.t, this.s, this.n, this.i, this.c, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Glass(
          child: Row(children: [
            Pic(icon: i, colors: [c, c.withValues(alpha: 0.7)], w: 40, h: 40, r: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.w800, color: navy, fontSize: 13)),
                Text(s, style: const TextStyle(fontSize: 10, color: grey)),
              ]),
            ),
            Text(n, style: const TextStyle(fontSize: 11, color: grey)),
          ]),
        ),
      );
}

// ---------- 9. MCQ QUIZ ----------

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // question, 4 options, correct index
  final qs = const [
    ['If the value of x in the equation 2x + 6 = 14 is:', '2', '3', '4', '6', 2],
    ['What is the value of 5² + 3?', '25', '28', '30', '15', 1],
    ['Solve: x − 7 = 12', '19', '5', '17', '20', 0],
  ];
  int q = 0;
  int? picked;

  @override
  Widget build(BuildContext context) {
    final d = qs[q];
    final correct = d[5] as int;
    return Scaffold(
      body: pageBody([
        const Row(children: [
          Expanded(child: Header('Mathematics - MCQ', 'Class 10  •  12 Questions  •  15 Minutes')),
          Tag('12:34', blue, Color(0xFFE4E9FF)),
        ]),
        gap,
        Glass(
          padding: const EdgeInsets.all(18),
          child: Text('Q${q + 5}. ${d[0]}',
              style: const TextStyle(fontWeight: FontWeight.w700, color: navy, height: 1.4)),
        ),
        gap,
        for (int i = 0; i < 4; i++)
          GestureDetector(
            onTap: () => setState(() => picked = i),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: picked == null
                    ? Colors.white.withValues(alpha: 0.1)
                    : (i == correct
                        ? const Color(0x551FB57A)
                        : (picked == i ? const Color(0x55E5484D) : Colors.white.withValues(alpha: 0.1))),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: picked != null && i == correct ? green : Colors.transparent, width: 1.6),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: const Color(0xFFE8EDFF),
                  child: Text('ABCD'[i], style: const TextStyle(fontSize: 11, color: blue, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(d[i + 1] as String, style: const TextStyle(color: navy, fontWeight: FontWeight.w600))),
                if (picked != null && i == correct) const Icon(Icons.check_circle_rounded, color: green),
              ]),
            ),
          ),
        const SizedBox(height: 20),
        Row(children: [
          TextButton.icon(
            onPressed: q > 0 ? () => setState(() { q--; picked = null; }) : null,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
            label: const Text('Previous'),
          ),
          Expanded(
            child: Center(
              child: Text('${q + 5} / 12', style: const TextStyle(color: navy, fontWeight: FontWeight.w700)),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              if (q < qs.length - 1) {
                q++;
                picked = null;
              } else {
                Navigator.pop(context);
              }
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              decoration: BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(24)),
              child: const Text('Next  →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ]),
    );
  }
}

Widget _orb(Color c, double d) => Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [c.withValues(alpha: 0.45), Colors.transparent]),
      ),
    );
// ---------- ANIMATED SPLASH (paste at the end of main.dart) ----------
// Needs at top of main.dart:  import 'dart:math' as math;
// And in ShikshaApp:          home: const SplashScreen(),

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400))..forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder<void>(
            pageBuilder: (_, _, _) => const LandingScreen(),
            transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          // 0 -> 0.35 : logo pops in
          final logoIn = Curves.easeOutBack.transform((t / 0.35).clamp(0.0, 1.0));
          // 0.3 -> 0.6 : text slides up and fades in
          final textIn = Curves.easeOut.transform(((t - 0.3) / 0.3).clamp(0.0, 1.0));
          // logo floats up and down, glow pulses
          final float = math.sin(t * math.pi * 4) * 7;
          final glow = 0.3 + 0.2 * math.sin(t * math.pi * 6);

          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(center: Alignment.topCenter, radius: 1.3, colors: [Color(0xFF2B3A8F), bg]),
            ),
            child: Stack(children: [
              Positioned(top: -60 + float * 2, right: -50, child: _orb(violet, 240)),
              Positioned(bottom: 90 - float * 2, left: -80, child: _orb(cyan, 220)),
              SafeArea(
                child: Column(children: [
                  const Spacer(flex: 3),
                  Transform.translate(
                    offset: Offset(0, float),
                    child: Transform.scale(
                      scale: logoIn,
                      child: Opacity(
                        opacity: logoIn.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [BoxShadow(color: blue.withValues(alpha: glow), blurRadius: 50, spreadRadius: 4)],
                          ),
                          child: const Pic(asset: 'assets/images/logo_icon.png', icon: Icons.school_rounded, w: 150, h: 150, r: 40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Opacity(
                    opacity: textIn,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - textIn)),
                      child: const Column(children: [
                        Text('Shiksha',
                            style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
                        SizedBox(height: 8),
                        Text('Learn  •  Grow  •  Build Your Future',
                            style: TextStyle(fontSize: 13, letterSpacing: 1, color: Color(0xFFDCE5FF))),
                      ]),
                    ),
                  ),
                  const Spacer(flex: 3),
                  SizedBox(
                    width: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: t,
                        minHeight: 6,
                        color: cyan,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Opacity(
                    opacity: textIn,
                    child: const Text('Loading your learning journey...',
                        style: TextStyle(fontSize: 12, letterSpacing: 1.5, color: Color(0xFF9AA6D8))),
                  ),
                  const Spacer(),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }
}



