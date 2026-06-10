import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlappyBirdGame extends FlameGame with TapCallbacks {
  FlappyBirdGame({required this.onChanged});

  static const _highScoreKey = 'northstar_flappy_high_score';
  static const _birdXFraction = 0.24;
  static const _birdRadius = 15.0;
  static const _groundHeight = 76.0;
  static const _jumpVelocity = -330.0;
  static const _gravity = 920.0;
  static const _pipeSpeed = 190.0;
  static const _pipeWidth = 70.0;
  static const _pipeGap = 170.0;
  static const _spawnInterval = 1.45;
  static const _topPadding = 64.0;
  static const _pipeMargin = 64.0;

  final VoidCallback onChanged;
  final math.Random _rng = math.Random();

  SharedPreferences? _prefs;
  Bird _bird = Bird(position: Vector2.zero());
  final List<PipePair> _pipes = [];

  double _spawnTimer = 0;
  bool _gameOver = false;
  bool _ready = false;
  int _score = 0;
  int _highScore = 0;

  bool get isReady => _ready;
  bool get isGameOver => _gameOver;
  int get score => _score;
  int get highScore => _highScore;

  @override
  Color backgroundColor() => const Color(0xFFBEE9FF);

  @override
  Future<void> onLoad() async {
    _prefs = await SharedPreferences.getInstance();
    _highScore = _prefs?.getInt(_highScoreKey) ?? 0;
    _ready = true;
    _reset();
    onChanged();
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    _bird.position = Vector2(_birdX, canvasSize.y * 0.45);
  }

  double get _birdX => size.x * _birdXFraction;
  double get _groundTop => math.max(0, size.y - _groundHeight);

  void _reset({bool keepHighScore = true}) {
    _pipes.clear();
    _score = 0;
    _spawnTimer = 0;
    _gameOver = false;
    _bird = Bird(position: Vector2(_birdX, size.y * 0.45));
    if (!keepHighScore) {
      _highScore = 0;
      _prefs?.remove(_highScoreKey);
    }
  }

  void restart() {
    if (!_ready) return;
    _reset();
    onChanged();
  }

  void _jump() {
    if (_gameOver) return;
    _bird.velocityY = _jumpVelocity;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_ready) return;
    if (_gameOver) {
      restart();
      return;
    }
    _jump();
    onChanged();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_ready || _gameOver) {
      return;
    }

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnPipePair();
    }

    _bird.updatePhysics(dt, gravity: _gravity);
    _bird.position.x = _birdX;

    for (final pipe in _pipes) {
      pipe.x -= _pipeSpeed * dt;
      if (!pipe.scored && pipe.x + _pipeWidth < _birdX) {
        pipe.scored = true;
        _score += 1;
        if (_score > _highScore) {
          _highScore = _score;
          _prefs?.setInt(_highScoreKey, _highScore);
        }
        onChanged();
      }
    }
    _pipes.removeWhere((pipe) => pipe.x + _pipeWidth < -20);

    if (_bird.hitsWorld(_groundTop, _birdRadius) ||
        _pipes.any((pipe) => pipe.collides(_bird, _groundTop))) {
      _gameOver = true;
      if (_score > _highScore) {
        _highScore = _score;
        _prefs?.setInt(_highScoreKey, _highScore);
      }
      onChanged();
    }
  }

  void _spawnPipePair() {
    final gapTopLimit = math.max(
      _topPadding,
      _groundTop - _pipeGap - _pipeMargin,
    );
    final gapTop = _topPadding +
        _rng.nextDouble() * math.max(1, gapTopLimit - _topPadding);
    _pipes.add(
      PipePair(
        x: size.x + 8,
        gapTop: gapTop,
        gapHeight: _pipeGap,
        pipeWidth: _pipeWidth,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _renderBackground(canvas);

    for (final pipe in _pipes) {
      pipe.render(canvas, _groundTop);
    }
    _bird.render(canvas);
    _renderHUD(canvas);

    if (_gameOver) {
      _renderOverlay(canvas);
    }
  }

  void _renderBackground(Canvas canvas) {
    final sky = Paint()..color = const Color(0xFFBEE9FF);
    canvas.drawRect(Offset.zero & Size(size.x, size.y), sky);

    final sunPaint = Paint()..color = const Color(0xFFFFD66B);
    canvas.drawCircle(Offset(size.x * 0.83, size.y * 0.16), 30, sunPaint);

    final groundPaint = Paint()..color = const Color(0xFF7ED957);
    canvas.drawRect(
      Rect.fromLTWH(0, _groundTop, size.x, size.y - _groundTop),
      groundPaint,
    );

    final groundShadow = Paint()..color = const Color(0xFF4A8E2D);
    canvas.drawRect(
      Rect.fromLTWH(0, _groundTop, size.x, 6),
      groundShadow,
    );
  }

  void _renderHUD(Canvas canvas) {
    _drawText(
      canvas,
      'Score: $_score',
      Offset(18, 18),
      color: const Color(0xFF19324B),
      size: 22,
      weight: FontWeight.w800,
    );
    _drawText(
      canvas,
      'High: $_highScore',
      Offset(size.x - 18, 18),
      color: const Color(0xFF19324B),
      size: 18,
      weight: FontWeight.w700,
      align: TextAlign.right,
    );

    if (!_gameOver) {
      _drawText(
        canvas,
        'Tap to jump',
        Offset(size.x / 2, size.y - 28),
        color: const Color(0xFF42627A),
        size: 16,
        weight: FontWeight.w600,
        align: TextAlign.center,
      );
    }
  }

  void _renderOverlay(Canvas canvas) {
    canvas.drawRect(
      Offset.zero & Size(size.x, size.y),
      Paint()..color = Colors.black.withValues(alpha: 0.26),
    );
    _drawText(
      canvas,
      'Game Over',
      Offset(size.x / 2, size.y * 0.36),
      color: Colors.white,
      size: 32,
      weight: FontWeight.w900,
      align: TextAlign.center,
    );
    _drawText(
      canvas,
      'Tap to restart',
      Offset(size.x / 2, size.y * 0.46),
      color: Colors.white,
      size: 18,
      weight: FontWeight.w600,
      align: TextAlign.center,
    );
    _drawText(
      canvas,
      'Best: $_highScore',
      Offset(size.x / 2, size.y * 0.54),
      color: Colors.white,
      size: 16,
      weight: FontWeight.w600,
      align: TextAlign.center,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required Color color,
    required double size,
    required FontWeight weight,
    TextAlign align = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: this.size.x - 32);

    final dx = align == TextAlign.center
        ? offset.dx - painter.width / 2
        : align == TextAlign.right
            ? offset.dx - painter.width
            : offset.dx;
    painter.paint(canvas, Offset(dx, offset.dy));
  }
}

class Bird {
  Bird({required this.position});

  Vector2 position;
  double velocityY = 0;
  static const double radius = 15.0;

  void updatePhysics(double dt, {required double gravity}) {
    velocityY += gravity * dt;
    position.y += velocityY * dt;
  }

  bool hitsWorld(double groundTop, double birdRadius) {
    final topHit = position.y - birdRadius <= 0;
    final bottomHit = position.y + birdRadius >= groundTop;
    return topHit || bottomHit;
  }

  Rect get bounds =>
      Rect.fromCircle(center: Offset(position.x, position.y), radius: radius);

  void render(Canvas canvas) {
    final body = Paint()..color = const Color(0xFFFFCF5A);
    final outline = Paint()
      ..color = const Color(0xFFE59B31)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final eye = Paint()..color = const Color(0xFF1F2937);

    canvas.drawCircle(Offset(position.x, position.y), radius, body);
    canvas.drawCircle(Offset(position.x, position.y), radius, outline);
    canvas.drawCircle(
      Offset(position.x + 5, position.y - 4),
      2.4,
      eye,
    );
    final beak = Paint()..color = const Color(0xFFF59E0B);
    final beakPath = Path()
      ..moveTo(position.x + radius - 2, position.y - 1)
      ..lineTo(position.x + radius + 8, position.y + 2)
      ..lineTo(position.x + radius - 2, position.y + 6)
      ..close();
    canvas.drawPath(beakPath, beak);
  }
}

class PipePair {
  PipePair({
    required this.x,
    required this.gapTop,
    required this.gapHeight,
    required this.pipeWidth,
  });

  double x;
  final double gapTop;
  final double gapHeight;
  final double pipeWidth;
  bool scored = false;

  Rect get _topRect => Rect.fromLTWH(x, 0, pipeWidth, gapTop);

  Rect _bottomRect(double groundTop) =>
      Rect.fromLTWH(x, gapTop + gapHeight, pipeWidth, groundTop - (gapTop + gapHeight));

  void render(Canvas canvas, double groundTop) {
    final fill = Paint()..color = const Color(0xFF2F9E44);
    final lip = Paint()..color = const Color(0xFF23733A);
    final shadow = Paint()..color = const Color(0xFF1A5B2A);

    final topRect = _topRect;
    final bottomRect = _bottomRect(groundTop);

    canvas.drawRect(topRect, fill);
    canvas.drawRect(bottomRect, fill);
    canvas.drawRect(
      Rect.fromLTWH(topRect.left - 6, topRect.bottom - 18, pipeWidth + 12, 18),
      lip,
    );
    canvas.drawRect(
      Rect.fromLTWH(bottomRect.left - 6, bottomRect.top, pipeWidth + 12, 18),
      lip,
    );
    canvas.drawRect(
      Rect.fromLTWH(topRect.left, topRect.top, 10, topRect.height),
      shadow,
    );
    canvas.drawRect(
      Rect.fromLTWH(bottomRect.left, bottomRect.top, 10, bottomRect.height),
      shadow,
    );
  }

  bool collides(Bird bird, double groundTop) {
    final birdRect = bird.bounds.inflate(-4);
    final topRect = _topRect;
    final bottomRect = _bottomRect(groundTop);
    return birdRect.overlaps(topRect) || birdRect.overlaps(bottomRect);
  }
}
