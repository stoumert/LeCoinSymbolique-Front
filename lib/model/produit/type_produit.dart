enum TypeProduit {
  ELECTRONIQUE,
  MEUBLE,
  OUTIL,
  VETEMENT,
  LIVRE,
  JEUVIDEO,
  AUTRE
}

String typeProduitToString(TypeProduit type) {
  return type.toString().split('.').last;
}

TypeProduit stringToTypeProduit(String type) {
  switch (type.toLowerCase()) {
    case 'electronique': return TypeProduit.ELECTRONIQUE;
    case 'meuble': return TypeProduit.MEUBLE;
    case 'outil': return TypeProduit.OUTIL;
    case 'vetement': return TypeProduit.VETEMENT;
    case 'livre': return TypeProduit.LIVRE;
    case 'jeuvideo': return TypeProduit.JEUVIDEO;
    default: return TypeProduit.AUTRE;
  }
}