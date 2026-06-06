class Report {
  final String id;
  final String titulo;
  final String descripcion;
  final String direccion;
  final String estado;
  final DateTime fecha;
  final String user;
  final String? userName;
  final String? userLastname;
  final String ciudad;
  final String categoria;
  final String? imagePath;
  final double? latitude;
  final double? longitude;

  Report({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.direccion,
    required this.estado,
    required this.fecha,
    required this.user,
    this.userName,
    this.userLastname,
    required this.ciudad,
    required this.categoria,
    this.imagePath,
    this.latitude,
    this.longitude,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'Pendiente',
      fecha:
          DateTime.tryParse(json['fecha']?.toString() ?? '') ?? DateTime.now(),
      user: json['user']?.toString() ?? '',
      userName: json['userName']?.toString(),
      userLastname: json['userLastname']?.toString(),
      ciudad: json['ciudad']?.toString() ?? 'Desconocido',
      categoria: json['categoria']?.toString() ?? 'General',
      imagePath: json['imagePath']?.toString(),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'direccion': direccion,
      'estado': estado,
      'fecha': fecha.toIso8601String(),
      'user': user,
      if (userName != null) 'userName': userName,
      if (userLastname != null) 'userLastname': userLastname,
      'ciudad': ciudad,
      'categoria': categoria,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
