class HsnCode {
  final String code;
  final String description;
  final String category;

  const HsnCode({
    required this.code,
    required this.description,
    required this.category,
  });
}

const List<HsnCode> commonHsnCodes = [
  // Food Products
  HsnCode(code: '0201', description: 'Meat of bovine animals, fresh or chilled', category: 'Food'),
  HsnCode(code: '0401', description: 'Milk and cream, not concentrated', category: 'Food'),
  HsnCode(code: '0901', description: 'Coffee', category: 'Food'),
  HsnCode(code: '0902', description: 'Tea', category: 'Food'),
  HsnCode(code: '1001', description: 'Wheat and meslin', category: 'Food'),
  HsnCode(code: '1006', description: 'Rice', category: 'Food'),
  HsnCode(code: '1101', description: 'Wheat or meslin flour', category: 'Food'),
  HsnCode(code: '1701', description: 'Cane or beet sugar', category: 'Food'),
  HsnCode(code: '1901', description: 'Food preparations of flour', category: 'Food'),
  HsnCode(code: '2106', description: 'Food preparations not elsewhere specified', category: 'Food'),
  
  // Textiles
  HsnCode(code: '5208', description: 'Woven fabrics of cotton', category: 'Textiles'),
  HsnCode(code: '6101', description: 'Knitted overcoats, jackets', category: 'Textiles'),
  HsnCode(code: '6109', description: 'T-shirts, singlets, tank tops', category: 'Textiles'),
  HsnCode(code: '6203', description: 'Suits, trousers, shorts (men)', category: 'Textiles'),
  HsnCode(code: '6204', description: 'Suits, dresses, skirts (women)', category: 'Textiles'),
  HsnCode(code: '6205', description: 'Shirts (men)', category: 'Textiles'),
  
  // Electronics
  HsnCode(code: '8471', description: 'Computers & processing units', category: 'Electronics'),
  HsnCode(code: '8473', description: 'Computer parts & accessories', category: 'Electronics'),
  HsnCode(code: '8517', description: 'Telephones, smartphones', category: 'Electronics'),
  HsnCode(code: '8518', description: 'Microphones, loudspeakers, headphones', category: 'Electronics'),
  HsnCode(code: '8521', description: 'Video recording apparatus', category: 'Electronics'),
  HsnCode(code: '8523', description: 'Discs, tapes, storage devices', category: 'Electronics'),
  HsnCode(code: '8528', description: 'Monitors, projectors, TVs', category: 'Electronics'),
  HsnCode(code: '8544', description: 'Insulated wire, cables', category: 'Electronics'),
  
  // Furniture
  HsnCode(code: '9401', description: 'Seats (other than dentist/barber chairs)', category: 'Furniture'),
  HsnCode(code: '9403', description: 'Other furniture', category: 'Furniture'),
  HsnCode(code: '9404', description: 'Mattress supports, mattresses', category: 'Furniture'),
  HsnCode(code: '9405', description: 'Lamps, lighting fittings', category: 'Furniture'),
  
  // Chemicals & Pharma
  HsnCode(code: '3003', description: 'Medicaments (not in dosage)', category: 'Pharma'),
  HsnCode(code: '3004', description: 'Medicaments (in dosage form)', category: 'Pharma'),
  HsnCode(code: '3005', description: 'Bandages, medical dressings', category: 'Pharma'),
  HsnCode(code: '3401', description: 'Soap, organic cleansing agents', category: 'Chemicals'),
  HsnCode(code: '3402', description: 'Detergents, cleaning preparations', category: 'Chemicals'),
  HsnCode(code: '3304', description: 'Beauty/makeup/skincare preparations', category: 'Chemicals'),
  
  // Services
  HsnCode(code: '9954', description: 'Construction services', category: 'Services'),
  HsnCode(code: '9961', description: 'Financial & insurance services', category: 'Services'),
  HsnCode(code: '9962', description: 'Real estate services', category: 'Services'),
  HsnCode(code: '9971', description: 'Business auxiliary services', category: 'Services'),
  HsnCode(code: '9972', description: 'Rental services of property', category: 'Services'),
  HsnCode(code: '9973', description: 'Leasing/rental without operator', category: 'Services'),
  HsnCode(code: '9983', description: 'Other professional services', category: 'Services'),
  HsnCode(code: '9984', description: 'Telecom, broadcasting, IT', category: 'Services'),
  HsnCode(code: '9985', description: 'Support and auxiliary services', category: 'Services'),
  HsnCode(code: '9986', description: 'Support services (agriculture, etc)', category: 'Services'),
  HsnCode(code: '9987', description: 'Maintenance and repair services', category: 'Services'),
  HsnCode(code: '9988', description: 'Manufacturing services', category: 'Services'),
  HsnCode(code: '9991', description: 'Public administration services', category: 'Services'),
  HsnCode(code: '9992', description: 'Education services', category: 'Services'),
  HsnCode(code: '9993', description: 'Health and social services', category: 'Services'),
  HsnCode(code: '9995', description: 'Recreation, cultural, sporting', category: 'Services'),
  HsnCode(code: '9996', description: 'Personal care services', category: 'Services'),
  HsnCode(code: '9997', description: 'Water supply, sewerage', category: 'Services'),
  
  // Automotive
  HsnCode(code: '8703', description: 'Motor cars & vehicles (passenger)', category: 'Automotive'),
  HsnCode(code: '8711', description: 'Motorcycles, mopeds', category: 'Automotive'),
  HsnCode(code: '8714', description: 'Parts for motorcycles, bicycles', category: 'Automotive'),
  
  // Stationery & Office
  HsnCode(code: '4802', description: 'Paper for writing/printing', category: 'Stationery'),
  HsnCode(code: '4820', description: 'Registers, notebooks, binders', category: 'Stationery'),
  HsnCode(code: '9608', description: 'Ball point pens, felt tip pens', category: 'Stationery'),
  
  // Jewellery
  HsnCode(code: '7113', description: 'Jewellery of precious metal', category: 'Jewellery'),
  HsnCode(code: '7114', description: 'Articles of goldsmith/silversmith', category: 'Jewellery'),
  HsnCode(code: '7117', description: 'Imitation jewellery', category: 'Jewellery'),
];
