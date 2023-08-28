CREATE TABLE Orders
    (
        Id INT PRIMARY KEY IDENTITY,
        ProductName VARCHAR(100) NOT NULL,
        OrderDate DATETIME2 NOT NULL
    )

INSERT INTO Orders(ProductName, OrderDate)
    VALUES
    ('Butter', '2016-09-19'),
    ('Milk', '2016-09-30'),
    ('Cheese', '2016-09-04'),
    ('Bread', '2015-12-20'),
    ('Tomatoes', '2015-12-30')


-- Solution
SELECT ProductName, OrderDate,
    DATEADD(DAY, 3, OrderDate) AS [Pay Due],
    DATEADD(MONTH, 1, OrderDate) AS [Deliver Due]
    FROM Orders

