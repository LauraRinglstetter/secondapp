// import 'package:flutter/material.dart' show BuildContext, ModalRoute;

// //Extension, um einfach und typensicher auf Route-Argument zugreifen zu können, die mit Navigator.pushNamed() übergeben werden:
// extension GetArgument on BuildContext {
//   T? getArgument<T>(){
//     final modalRoute = ModalRoute.of(this);
//     if(modalRoute != null) {
//       final args = modalRoute.settings.arguments;
//       if (args != null && args is T) {
//         return args as T;
//       }
//     }
//     return null;
//   }
// }