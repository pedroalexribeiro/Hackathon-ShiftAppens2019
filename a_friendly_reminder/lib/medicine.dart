/// MedicineModel.dart
import 'dart:convert';

Medicine medicineFromJson(String str) {
    final jsonData = json.decode(str);
    return Medicine.fromJson(jsonData);
}

String medicineToJson(Medicine data) {
    final dyn = data.toJson();
    return json.encode(dyn);
}

class Medicine{
    int id;
    String name;
    String interval;
    String img;

    Medicine({
        this.id,
        this.name,
        this.interval,
        this.img
    });

    factory Medicine.fromJson(Map<String, dynamic> json) => new Medicine(
        id: json["id"],
        name: json["name"],
        interval: json["interval"],
        img: json["img"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "interval": interval,
        "img": img
    };
}