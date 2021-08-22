# BlurMatrix
A Flutter widget that draws a matrix of colors like gradients also with simple animation.

![Image](https://github.com/alnitak/blur_matrix/blob/master/images/BlurMatrix.gif)
![Image](https://github.com/alnitak/blur_matrix/blob/master/images/screenshot.png)

### How to use

Define a List of List of colors like this:

```dart
colors = [
      [Colors.red,            Colors.blue,             Colors.yellowAccent],
      [Colors.green,          Colors.black,            Colors.cyanAccent],
      [Colors.yellowAccent,   Colors.deepPurpleAccent, Colors.white],
      [Colors.red,            Colors.blue,             Colors.yellowAccent],
    ];
```

or maybe like this for a Shimmer effect like result:

```dart
colors = [
  [Colors.black.withOpacity(0.6),      Colors.white.withOpacity(0.8)],
];
```
Then use BlurMatrix or BlurMatrixAnimate:

```dart
Container(
  width: 250,
  height: 250,
  child: BlurMatrixAnimate(
    colors: colors,
  ),
),
```

This widget could be a start for nice effects, so if you have some nice idea, please le me know!