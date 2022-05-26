connect to SE3DB3;

/* q1 */
SELECT DISTINCT FirsTNAME, LasTName, DateOfBirth FROM Order
WHERE Date LIKE '07/22/2020' AND (Date - 18 YEARS) >= DateOfBirth;

/* q2 */
SELECT DISTINCT OC.ProductID, cate.Name
FROM ProductCategory cate, OrderContains OC, Order, BelongsTo bt
WHERE YEAR(Order.Date - Order.DateOfBirth) BETWEEN 20 AND 35 AND Order.OrderID = OC.OrderID AND
      cate.ProductCategoryID = bt.ProductCategoryID AND OC.ProductID = bt.ProductID;

/* q3 */
SELECT x.FirstName, x.LastName, x.DateofBirth, Person.City, Person.Country
FROM Person, (SELECT DISTINCT FirstName, LastName, DateOfBirth FROM WriteReview
              GROUP BY FirstName, LastName, DateOfBirth
              HAVING COUNT(*) = (SELECT COUNT(*) AS freq FROM WriteReview
                                 GROUP BY (FirstName, LastName, DateOfBirth)
                                 ORDER BY freq DESC
                                 FETCH FIRST 1 ROW ONLY)
             ) x
WHERE x.FirstName = Person.FirstName AND x.LastName = Person.LastName AND x.DateofBirth = Person.DateofBirth;

/* q4a */
SELECT COUNT(TrackingNumber) - COUNT(DISTINCT TrackingNumber) FROM HasShipment;

/* q4b */
SELECT TrackingNumber
FROM Order, Person, (SELECT OrderID, TrackingNumber FROM HasShipment
                     WHERE TrackingNumber IN (SELECT TrackingNumber FROM HasShipment GROUP BY TrackingNumber HAVING COUNT(TrackingNumber) > 1)
                    ) z
WHERE z.OrderID = Order.OrderID AND Order.FirstName = Person.FirstName AND Order.LastName = Person.LastName AND
      Order.DateOfBirth = Person.DateOfBirth AND Person.Country = 'Canada' AND Person.PostalCode LIKE 'M%';

/* q5 */
SELECT ProductID FROM BelongsTo GROUP BY ProductID HAVING COUNT(ProductID) = 1;

/* q6a */
SELECT Product.ProductID, Product.Name, p.Brand
FROM (Select Brand FROM Product GROUP BY Brand Having COUNT(ProductID) = 1) p, Product
WHERE p.Brand = Product.Brand;

/* q6b */
SELECT m1.OrderID
FROM
    (SELECT m.OrderID, SUM(m.RDR1) as Sales#
     FROM (SELECT OC.OrderID, pro.Price * OC.Quantity as RDR1
           FROM Product pro, OrderContains OC
           WHERE pro.ProductID = OC.ProductID
           ) m
     GROUP BY OrderID
    ) m1,
    (SELECT SUM(m.RDR1) as Sales#
     FROM (SELECT OC.OrderID, pro.Price * OC.Quantity as RDR1
           FROM Product pro, OrderContains OC
           WHERE pro.ProductID = OC.ProductID
           ) m
     GROUP BY OrderID
     ORDER BY Sales# DESC
     FETCH FIRST 1 ROW ONLY
    ) m2
WHERE m1.Sales# >= m2.Sales#;

/* q7 */
SELECT StoreID, Description, StartDate, SUM(LineSales) as Revenue
FROM
    (
    SELECT m.StoreID, m.LineSales, st.Description, st.StartDate
    FROM (SELECT OC.OrderID, OC.ProductID, pro.Price * OC.Quantity as LineSales, pro.StoreID, or.Date
          FROM Product pro, OrderContains OC, Order or
          WHERE pro.ProductID = OC.ProductID AND oc.OrderID = or.OrderID AND or.Date BETWEEN '07/01/2020' AND '07/31/2020'
         ) m, Store st
    WHERE m.StoreID = st.StoreID
    )
GROUP BY StoreID, Description, StartDate ORDER BY Revenue ASC;

/* q8a */
SELECT ProductID, Name, Brand FROM Product
WHERE ProductID NOT IN (SELECT ProductID FROM OrderContains);

/* q8b */
SELECT ProductID
FROM (SELECT ProductID FROM Product WHERE ProductID NOT IN (SELECT ProductID FROM OrderContains))
WHERE ProductID IN (SELECT ProductID FROM Promotion);

/* q9a */
SELECT CheckPro.ProductCategoryID, (SELECT Name FROM ProductCategory WHERE ProductCategory.ProductCategoryID = CheckPro.ProductCategoryID)
FROM (SELECT ProductCategoryID, COUNT(ProductID) CountPID FROM BelongsTo GROUP BY ProductCategoryID) CheckPro, /* count the quantity of products in each category */
     (SELECT CAW.ProductCategoryID, COUNT(ProductID) AS CountWarr
      FROM (SELECT DISTINCT BelongsTo.ProductID, BelongsTo.ProductCategoryID FROM BELONGSTO
            LEFT JOIN HasWarranty ON BelongsTo.ProductID = HasWarranty.ProductID) CAW
      GROUP BY CAW.ProductCategoryID) CheckWarr
WHERE CheckPro.CountPID = CheckWarr.CountWarr AND CheckPro.ProductCategoryID = CheckWarr.ProductCategoryID;

/* q9b */
SELECT CheckStore.StoreID
/*, CheckPro.ProductCategoryID, (SELECT Name FROM ProductCategory WHERE ProductCategory.ProductCategoryID = CheckPro.ProductCategoryID) */
FROM (SELECT ProductCategoryID, COUNT(ProductID) CountPID FROM BelongsTo GROUP BY ProductCategoryID) CheckPro, /* count the quantity of products in each category */

     (SELECT CAW.ProductCategoryID, COUNT(ProductID) AS CountWarr
      FROM (SELECT DISTINCT BelongsTo.ProductID, BelongsTo.ProductCategoryID FROM BELONGSTO
            LEFT JOIN HasWarranty ON BelongsTo.ProductID = HasWarranty.ProductID) CAW
      GROUP BY CAW.ProductCategoryID) CheckWarr,

     (SELECT Product.StoreID, ProductCategoryID, COUNT(Product.ProductID) AS CountStore FROM PRODUCT
      LEFT JOIN BelongsTo ON Product.ProductID = BelongsTo.ProductID GROUP BY StoreID, ProductCategoryID) CheckStore

WHERE CheckPro.CountPID = CheckWarr.CountWarr AND CheckStore.CountStore = CheckPro.CountPID AND
      CheckPro.ProductCategoryID = CheckWarr.ProductCategoryID AND
      CheckStore.ProductCategoryId = CheckPro.ProductCategoryID;

/* q10a */
SELECT T.ProductID, Product.Name, Product.ModelNumber
FROM (SELECT ProductID, AvgStar, SUM(AvgRe*CountStar)/SUM(CountStar) AllRe
      FROM (SELECT x1.ProductID, x1.AvgStar, y1.AvgRe, y1.CountStar
            FROM (SELECT Pro.ProductID, Pro.AvgStar, BelongsTo.ProductCategoryID
                  FROM (SELECT ProductID, AVG(STAR) AvgStar
                        FROM (SELECT WriteReview.ProductID, WriteReview.Star FROM WriteReview INNER JOIN BelongsTo ON WriteReview.ProductID = BelongsTo.ProductID)
                        GROUP BY ProductID
                       ) Pro
                  INNER JOIN BelongsTo ON Pro.ProductID = BelongsTo.ProductID
                  ) x1, /* average star for ProductID  + corresponding ProductCategoryID */
                  (SELECT ProductCategoryID, AVG(STAR) AvgRe, COUNT(Star) CountStar
                   FROM (SELECT WriteReview.Star, BelongsTo.ProductCategoryID FROM WriteReview INNER JOIN BelongsTo ON WriteReview.ProductID = BelongsTo.ProductID)
                   GROUP BY ProductCategoryID
                  ) y1 /* average star for ProductCategoryID */
            WHERE x1.ProductCategoryID = y1.ProductCategoryID
           )
      GROUP BY ProductID, AvgStar
      ) T
INNER JOIN Product ON T.ProductID = Product.ProductID WHERE T.AvgStar > T.AllRe;

/* q10b */
SELECT A1.ProductID, A1.Price * A2.TotalQuan AS Revenue
FROM (SELECT DISTINCT T3.ProductID, Product.Price
      FROM (SELECT ProductID
    FROM (SELECT ProductID, AvgStar, SUM(AvgRe*CountStar)/SUM(CountStar) AllRe
          FROM (SELECT x1.ProductID, x1.AvgStar, y1.AvgRe, y1.CountStar
                FROM (SELECT Pro.ProductID, Pro.AvgStar, BelongsTo.ProductCategoryID
                      FROM (SELECT ProductID, AVG(STAR) AvgStar
                            FROM (SELECT WriteReview.ProductID, WriteReview.Star FROM WriteReview INNER JOIN BelongsTo ON WriteReview.ProductID = BelongsTo.ProductID)
                            GROUP BY ProductID
                           ) Pro
                     INNER JOIN BelongsTo ON Pro.ProductID = BelongsTo.ProductID
                     ) x1, /* average star for ProductID  + corresponding ProductCategoryID */
                     (SELECT ProductCategoryID, AVG(STAR) AvgRe, COUNT(Star) CountStar
                      FROM (SELECT WriteReview.Star, BelongsTo.ProductCategoryID FROM WriteReview INNER JOIN BelongsTo ON WriteReview.ProductID = BelongsTo.ProductID)
                      GROUP BY ProductCategoryID
                     ) y1 /* average star for ProductCategoryID */
                WHERE x1.ProductCategoryID = y1.ProductCategoryID
               )
          GROUP BY ProductID, AvgStar
          ) T
    WHERE T.AvgStar > T.AllRe) T3, Product
      WHERE T3.ProductID = Product.ProductID) A1,
     (SELECT ProductID, SUM(quantity) as TotalQuan FROM OrderContains GROUP BY ProductID) A2
WHERE A1.ProductID = A2.ProductID
ORDER BY Revenue DESC;
