                                 // CREATE Questions
CREATE
(Alice:User {name:'Alice', email:'alice@example.com'}),
(Bob:User {name:'Bob', email:'bob@example.com'}),
(Charlie:User {name:'Charlie', email:'charlie@example.com'}),

(Product1:Product {name:'Product1', category:'Electronics', price:49.99}),
(Product2:Product {name:'Product2', category:'Books', price:29.99}),
(Product3:Product {name:'Product3', category:'Clothing', price:39.99}),

(Electronics:Category {name:'Electronics'}),
(Books:Category {name:'Books'}),
(Clothing:Category {name:'Clothing'}),

(BrandA:Brand {name:'BrandA'}),
(BrandB:Brand {name:'BrandB'}),
(BrandC:Brand {name:'BrandC'}),

(Review1:Review {name:'Review1', rating:5}),
(Review2:Review {name:'Review2', rating:4}),
(Review3:Review {name:'Review3', rating:3}),


// (6) Alice bought Product1
(Alice)-[:BOUGHT {date:'2025-10-14', quantity:2, price_paid:99.98}]->(Product1),

// (7) Bob bought Product2
(Bob)-[:BOUGHT {date:'2025-10-13', quantity:1, price_paid:29.99}]->(Product2),

// (8) Charlie viewed Product3
(Charlie)-[:VIEWED {date:'2025-10-12', duration_seconds:120, device:'mobile'}]->(Product3),

// (9) Product1 belongs to Electronics
(Product1)-[:BELONGS_TO {added_date:'2025-01-01'}]->(Electronics),

// (10) Product1 made by BrandA
(Product1)-[:MADE_BY {launch_year:2024}]->(BrandA),

// (11) Alice rated Review1, and Review1 reviews Product1
(Alice)-[:RATED {rating:5, review_date:'2025-10-14'}]->(Review1),
(Review1)-[:REVIEWS]->(Product1),

// (12) Product1 similar to Product3
(Product1)-[:SIMILAR_TO {similarity_score:0.85}]->(Product3),

// (13) Alice friends with Bob
(Alice)-[:FRIENDS_WITH {since:'2023-01-01', interaction_count:15}]->(Bob),

// (14) Charlie bought Product2
(Charlie)-[:BOUGHT {date:'2025-10-14', quantity:1, price_paid:29.99}]->(Product2),

// (15) Alice viewed Product2
(Alice)-[:VIEWED {date:'2025-10-13', duration_seconds:45, device:'desktop'}]->(Product2);


                                   // QUERY Questions


// 16. Products purchased by Alice
MATCH (u:User {name:'Alice'})-[b:BOUGHT]->(p:Product)
RETURN p.name AS Product, b.quantity AS Quantity, b.date AS PurchaseDate;

// 17. Recommend products for Alice (based on Bob’s recent purchases)
MATCH (a:User {name:'Alice'})-[:FRIENDS_WITH]->(b:User {name:'Bob'})-[bo:BOUGHT]->(p:Product)
WHERE date(bo.date) >= date('2025-09-14')
RETURN DISTINCT p.name AS RecommendedProducts;

// 18. All products in Electronics category
MATCH (p:Product)-[r:BELONGS_TO]->(c:Category {name:'Electronics'})
RETURN p.name AS Product, r.added_date AS AddedDate;

// 19. Top 5 products by average rating
MATCH (r:Review)-[:REVIEWS]->(p:Product)
RETURN p.name AS Product, avg(r.rating) AS AvgRating
ORDER BY AvgRating DESC LIMIT 5;

// 20. Products made by BrandB
MATCH (p:Product)-[m:MADE_BY]->(b:Brand {name:'BrandB'})
RETURN p.name AS Product, m.launch_year AS LaunchYear;

// 21. Users who viewed Product3 but didn’t buy it
MATCH (u:User)-[v:VIEWED]->(p:Product {name:'Product3'})
WHERE NOT (u)-[:BOUGHT]->(p)
RETURN u.name AS User, v.duration_seconds AS Duration, v.device AS Device;

// 22. Category with highest total purchase quantity
MATCH (u:User)-[b:BOUGHT]->(p:Product)-[:BELONGS_TO]->(c:Category)
RETURN c.name AS Category, SUM(b.quantity) AS TotalQuantity
ORDER BY TotalQuantity DESC LIMIT 1;

// 23. Users who rated Product1 with 5 stars
MATCH (u:User)-[r:RATED {rating:5}]->(:Review)-[:REVIEWS]->(p:Product {name:'Product1'})
RETURN u.name AS User, r.review_date AS ReviewDate;

// 24. Products similar to Product1 (similarity > 0.8)
MATCH (p1:Product {name:'Product1'})-[s:SIMILAR_TO]->(p2:Product)
WHERE s.similarity_score > 0.8
RETURN p2.name AS SimilarProduct, s.similarity_score AS SimilarityScore;

// 25. Friends of Alice who bought Product2
MATCH (a:User {name:'Alice'})-[:FRIENDS_WITH]->(f:User)-[b:BOUGHT]->(p:Product {name:'Product2'})
RETURN f.name AS Friend, b.date AS PurchaseDate;

// 26. All reviews for Product2
MATCH (u:User)-[r:RATED]->(rev:Review)-[:REVIEWS]->(p:Product {name:'Product2'})
RETURN u.name AS User, rev.name AS Review, r.rating AS Rating;

// 27. Users who bought from multiple categories
MATCH (u:User)-[:BOUGHT]->(p:Product)-[:BELONGS_TO]->(c:Category)
WITH u, COLLECT(DISTINCT c.name) AS Categories, COLLECT(p.name) AS Products
WHERE SIZE(Categories) > 1
RETURN u.name AS User, Products, Categories;

// 28. Products viewed >100 seconds
MATCH (u:User)-[v:VIEWED]->(p:Product)
WHERE v.duration_seconds > 100
RETURN DISTINCT p.name AS Product;

// 29. Recommend based on friends’ recent purchases
MATCH (a:User {name:'Alice'})-[:FRIENDS_WITH]->(f:User)-[b:BOUGHT]->(p:Product)
WHERE date(b.date) >= date() - duration('P30D')
RETURN DISTINCT p.name AS Recommended;

// 30. Products frequently bought together with Product2
MATCH (u:User)-[b1:BOUGHT]->(p1:Product {name:'Product2'}),
      (u)-[b2:BOUGHT]->(p2:Product)
WHERE p1 <> p2
RETURN DISTINCT p2.name AS BoughtTogether, b2.date AS PurchaseDate;



                          // UPDATE Questions


// 31. Update the price of Product1 to 99.99
MATCH (p:Product {name:'Product1'})
SET p.price = 99.99;

// 32. Add Product1 to a new category “Gadgets” with added_date 2025-10-14
MATCH (p:Product {name:'Product1'})
MERGE (g:Category {name:'Gadgets'})
CREATE (p)-[:BELONGS_TO {added_date:'2025-10-14'}]->(g);

// 33. Update Alice’s email
MATCH (u:User {name:'Alice'})
SET u.email = 'alice_new@example.com';

// 34. Update Review1 rating to 4 on 2025-10-15
MATCH (r:Review {name:'Review1'})
SET r.rating = 4,
    r.updated_date = '2025-10-15';

// 35. Add BOUGHT relationship: Charlie bought Product3
MATCH (u:User {name:'Charlie'}), (p:Product {name:'Product3'})
CREATE (u)-[:BOUGHT {date:'2025-10-14', quantity:1, price_paid:39.99}]->(p);

// 36. Change the brand of Product3 from BrandC to BrandD, launch_year 2025
MATCH (p:Product {name:'Product3'})-[r:MADE_BY]->(:Brand {name:'BrandC'})
DELETE r
MERGE (b:Brand {name:'BrandD'})
CREATE (p)-[:MADE_BY {launch_year:2025}]->(b);

// 37. Rename Product2 to “BookMaster 2025”
MATCH (p:Product {name:'Product2'})
SET p.name = 'BookMaster 2025';

// 38. Update names of users Bob → Robert, Charlie → Charles
MATCH (u:User)
WHERE u.name IN ['Bob', 'Charlie']
SET u.name = CASE u.name
    WHEN 'Bob' THEN 'Robert'
    WHEN 'Charlie' THEN 'Charles'
END;

// 39. Change category of Product3 from Clothing to Sports, added_date 2025-10-14
MATCH (p:Product {name:'Product3'})-[r:BELONGS_TO]->(:Category {name:'Clothing'})
DELETE r
MERGE (s:Category {name:'Sports'})
CREATE (p)-[:BELONGS_TO {added_date:'2025-10-14'}]->(s);

// 40. Add new attribute discount = 10% to Product1
MATCH (p:Product {name:'Product1'})
SET p.discount = 0.10;



                             // Delete Questions



// 41. Delete Product50
MATCH (p:Product {name:'Product50'}) DETACH DELETE p;

// 42. Delete Review5 with rating 2
MATCH (r:Review {name:'Review5', rating:2}) DETACH DELETE r;

// 43. Remove BOUGHT relationship between Alice and Product2
MATCH (:User {name:'Alice'})-[b:BOUGHT]->(:Product {name:'Product2'})
DELETE b;

// 44. Delete category “OldCategory” and relationships
MATCH (c:Category {name:'OldCategory'}) DETACH DELETE c;

// 45. Delete user Tina and relationships
MATCH (u:User {name:'Tina'}) DETACH DELETE u;

// 46. Remove SIMILAR_TO between Product1 and Product3
MATCH (:Product {name:'Product1'})-[s:SIMILAR_TO]->(:Product {name:'Product3'})
DELETE s;

// 47. Delete all products made by BrandJ
MATCH (p:Product)-[:MADE_BY]->(:Brand {name:'BrandJ'})
DETACH DELETE p;

// 48. Delete VIEWED relationships for Product3 before 2025-01-01
MATCH (:User)-[v:VIEWED]->(:Product {name:'Product3'})
WHERE date(v.date) < date('2025-01-01')
DELETE v;

// 49. Delete products never bought or reviewed (Product48, Product49)
MATCH (p:Product)
WHERE p.name IN ['Product48','Product49']
  AND NOT ( ()-[:BOUGHT]->(p) OR ()-[:REVIEWS]->(p) )
DETACH DELETE p;

// 50. Delete Review3 but keep Product3
MATCH (r:Review {name:'Review3'})
DETACH DELETE r;


                          // ANALYTICAL / COMPLEX Query Questions


// 51. Find top 5 users by purchase quantity in October 2025
MATCH (u:User)-[b:BOUGHT]->(p:Product)
WHERE b.date >= '2025-10-01' AND b.date <= '2025-10-31'
RETURN u.name AS User, SUM(b.quantity) AS TotalQuantity
ORDER BY TotalQuantity DESC
LIMIT 5;

// 52. Recommend products for Alice based on purchases in Electronics category
MATCH (alice:User {name:'Alice'})
MATCH (alice)-[:BOUGHT]->(:Product)-[:BELONGS_TO]->(:Category {name:'Electronics'})
MATCH (other:User)-[:BOUGHT]->(prod:Product)-[:BELONGS_TO]->(:Category {name:'Electronics'})
WHERE other <> alice
AND NOT (alice)-[:BOUGHT]->(prod)
RETURN DISTINCT prod.name AS RecommendedProduct, prod.price AS Price;

// 53. Identify products frequently bought together with Product2 in the last 30 days
MATCH (u:User)-[b1:BOUGHT]->(p1:Product {name:'Product2'})
MATCH (u)-[b2:BOUGHT]->(p2:Product)
WHERE p2 <> p1 AND b2.date >= date('2025-09-16')
RETURN p2.name AS CoPurchasedProduct, COUNT(*) AS Frequency
ORDER BY Frequency DESC;

// 54. Find average rating for products made by BrandA
MATCH (p:Product)-[:MADE_BY]->(:Brand {name:'BrandA'})
MATCH (p)<-[:REVIEWS]-(r:Review)
RETURN p.name AS Product, AVG(r.rating) AS AverageRating;

// 55. Suggest products for Alice based on her friends’ purchases, including purchase dates
MATCH (alice:User {name:'Alice'})-[:FRIENDS_WITH]-(friend:User)
MATCH (friend)-[b:BOUGHT]->(p:Product)
WHERE NOT (alice)-[:BOUGHT]->(p)
RETURN DISTINCT p.name AS SuggestedProduct, friend.name AS Friend, b.date AS PurchaseDate
ORDER BY b.date DESC;

// 56. Find users who bought products with price_paid > 80
MATCH (u:User)-[b:BOUGHT]->(p:Product)
WHERE b.price_paid > 80
RETURN u.name AS User, p.name AS Product, b.price_paid AS PricePaid;

// 57. Identify categories generating the highest total revenue (sum of price_paid × quantity)
MATCH (u:User)-[b:BOUGHT]->(p:Product)-[:BELONGS_TO]->(c:Category)
RETURN c.name AS Category, SUM(b.price_paid) AS TotalRevenue
ORDER BY TotalRevenue DESC;

// 58. Find products viewed >100 seconds but never bought
MATCH (u:User)-[v:VIEWED]->(p:Product)
WHERE v.duration_seconds > 100
AND NOT (u)-[:BOUGHT]->(p)
RETURN DISTINCT p.name AS Product, v.duration_seconds AS Duration, u.name AS Viewer;

// 59. List products with review count and average rating
MATCH (p:Product)<-[:REVIEWS]-(r:Review)
RETURN p.name AS Product, COUNT(r) AS ReviewCount, AVG(r.rating) AS AverageRating
ORDER BY AverageRating DESC;

// 60. Identify potential bundles of Product1, Product2, Product3 based on co-purchases
MATCH (u:User)-[:BOUGHT]->(p:Product)
WHERE p.name IN ['Product1', 'Product2', 'Product3']
WITH u, COLLECT(p.name) AS products
WHERE SIZE(products) > 1
RETURN products AS Bundle, COUNT(*) AS Frequency
ORDER BY Frequency DESC;
