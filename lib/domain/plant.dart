import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String id;
  final String userId;
  final String commonName;
  final String scientificName;
  final String description;
  final String watering;

  String imageUrl;

  Plant({
    this.id = '',
    required this.userId,
    required this.commonName,
    required this.scientificName,
    required this.description,
    required this.watering,
    this.imageUrl ='',
  });

  Plant.forRegistration({
    required this.commonName,
    required this.scientificName,
    required this.description,
    required this.watering,
  }) : id = '', 
       userId = '',
       imageUrl= '';

  factory Plant.fromFirestore(DocumentSnapshot doc){
    Map data = doc.data() as Map;
    return Plant(
      id: doc.id,
      userId: data['userId'], 
      commonName: data['commonName'], 
      scientificName: data['scientificName'], 
      description: data['description'], 
      watering: data["watering"]
    );
  }
  Map<String,dynamic> toFirestore(){
    return{
      'id':id,
      'userId':userId,
      "commonName": commonName, 
      "scientificName": scientificName, 
      "description": description, 
      "watering": watering,
    };
  }
}

