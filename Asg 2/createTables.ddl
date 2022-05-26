--connect to SE3DB3;

------------------------------------------------
--  DDL Statements for table Person
------------------------------------------------
create table Person(
	FirstName varchar(60) not null,
	LastName varchar(60) not null,
	DateOfBirth DATE  not null,
	Sex varchar(10),
	PostalCode varchar(60),
	Street varchar(60),
	City varchar(60),
	Country varchar(60),
	primary key (FirstName, LastName, DateOfBirth)
);

------------------------------------------------
--  DDL Statements for table Phone
------------------------------------------------
create table Phone(
	FirstName varchar(60) not null,
	LastName varchar(60) not null,
	DateOfBirth DATE not null,
	Number bigint not null,
	Type varchar(20),
	primary key (Number),
	foreign key (FirstName, LastName, DateOfBirth)
	    references Person (FirstName, LastName, DateOfBirth) on delete cascade
);

------------------------------------------------
--  DDL Statements for table StoreOwner
------------------------------------------------
create table StoreOwner(
	FirstName varchar(60) not null,
	LastName varchar(60) not null,
	DateOfBirth DATE  not null,
	BusinessExpenses bigint,
	primary key (FirstName, LastName, DateOfBirth),
	foreign key (FirstName, LastName, DateOfBirth)
	    references Person (FirstName, LastName, DateOfBirth) on delete cascade
);

------------------------------------------------
--  DDL Statements for table StoreEmployee
------------------------------------------------
create table StoreEmployee(
	FirstName varchar(60) not null,
	LastName varchar(60) not null,
	DateOfBirth DATE  not null,
	YearsOfService INTEGER,
    Salary         INTEGER,
	primary key (FirstName, LastName, DateOfBirth),
	foreign key (FirstName, LastName, DateOfBirth)
	    references Person (FirstName, LastName, DateOfBirth) on delete cascade
);

------------------------------------------------
--  DDL Statements for table Customer
------------------------------------------------
create table Customer(
	FirstName varchar(60) not null,
	LastName varchar(60) not null,
	DateOfBirth DATE not null,
	Membership varchar(50),
	primary key (FirstName, LastName, DateOfBirth),
	foreign key (FirstName, LastName, DateOfBirth)
	    references Person (FirstName, LastName, DateOfBirth) on delete cascade
);

------------------------------------------------
--  DDL Statements for table Order
------------------------------------------------
create table Order(
	FirstName varchar(60) not null,
	LastName varchar(60) not null,
	DateOfBirth DATE  not null,
	OrderID varchar(12) not null,
	Date DATE,
	Time varchar(15),
	primary key (OrderID),
	foreign key (FirstName, LastName, DateOfBirth)
	    references Person (FirstName, LastName, DateOfBirth) on delete cascade
);

------------------------------------------------
--  DDL Statements for table Shipment - TrackingNumber,Carrier,DeliveryDate
------------------------------------------------
create table Shipment(
	TrackingNumber varchar(15) not null,
	DeliveryDate DATE,
	Carrier varchar(30),
	primary key (TrackingNumber)
);

------------------------------------------------
--  DDL Statements for table HasShipment - TrackingNumber,OrderID
------------------------------------------------
create table HasShipment(
	TrackingNumber varchar(15) not null,
    OrderID varchar(12) not null,
	primary key (TrackingNumber,OrderID),
    foreign key (TrackingNumber)
        references Shipment (TrackingNumber) on delete cascade,
    foreign key (OrderID)
        references Order (OrderID) on delete cascade
);

------------------------------------------------
--  DDL Statements for table Store - StoreID,Description,Page,StartDate,OwnerFirstName,OwnerLastName,OwnerDoB
------------------------------------------------
create table Store(
    StoreID int not null,
    Description varchar(50),
    Page varchar(50),
    StartDate DATE,
    OwnerFirstName varchar(60) not null,
    OwnerLastName varchar(60) not null,
    OwnerDoB DATE  not null,
	primary key (StoreID),
    foreign key (OwnerFirstName, OwnerLastName, OwnerDoB)
        references StoreOwner (FirstName, LastName, DateOfBirth) on delete cascade
);

------------------------------------------------
--  DDL Statements for table Works - StoreID,EmployeeFirstName,EmployeeLastName,EmployeeDoB
------------------------------------------------
create table Works(
    StoreID int not null,
    EmployeeFirstName varchar(60) not null,
    EmployeeLastName varchar(60) not null,
    EmployeeDoB DATE  not null,
	primary key (StoreID,EmployeeFirstName,EmployeeLastName,EmployeeDoB),
    foreign key (EmployeeFirstName, EmployeeLastName, EmployeeDoB)
        references StoreEmployee (FirstName, LastName, DateOfBirth) on delete cascade,
    foreign key (StoreID)
        references Store (StoreID) on delete cascade
);

------------------------------------------------
--  DDL Statements for table Product
------------------------------------------------

CREATE TABLE Product (
    ProductID int not null,
    Name varchar(255) not null,
    ModelNumber int not null,
    Description varchar(5000) not null,
    Brand varchar(255) not null,
    Price int not null,
    StoreID int not null,
    primary key (ProductID),
    foreign key (StoreID)
        references Store (StoreID) on delete cascade
);

------------------------------------------------
--  DDL Statements for table OrderContains - OrderID,ProductID,Quantity
------------------------------------------------
create table OrderContains(
    OrderID varchar(12) not null,
    ProductID int not null,
    Quantity int,
	primary key (OrderID,ProductID),
    foreign key (OrderID)
        references Order (OrderID) on delete cascade,
    foreign key (ProductID)
        references Product (ProductID) on delete cascade
);

------------------------------------------------
--  DDL Statements for table ProductCategory
------------------------------------------------

CREATE TABLE ProductCategory (
    ProductCategoryID int not null,
    Name varchar(255) not null,
    Description varchar(255) not null,
    primary key (ProductCategoryID)
);

------------------------------------------------
--  DDL Statements for table BelongsTo
------------------------------------------------

CREATE TABLE BelongsTo (
    ProductCategoryID int not null,
    ProductID int not null,
    primary key (ProductCategoryID,ProductID),
    foreign key (ProductCategoryID)
        references ProductCategory (ProductCategoryID) on delete cascade,
    foreign key (ProductID)
        references Product (ProductID) on delete cascade
);

------------------------------------------------
--  DDL Statements for table Promotion
------------------------------------------------

CREATE TABLE Promotion (
    Name varchar(255) not null,
    StartDate date not null,
    EndDate date not null,
    ProductID int not null,
    primary key (Name,StartDate,EndDate,ProductID),
    foreign key (ProductID)
        references Product (ProductID) on delete cascade
);

------------------------------------------------
--  DDL Statements for table Warranty
------------------------------------------------

CREATE TABLE Warranty (
    WarrantyID int not null,
    Type varchar(255) not null,
    Duration int not null,
    primary key (WarrantyID)
);

------------------------------------------------
--  DDL Statements for table HasWarranty
------------------------------------------------

CREATE TABLE HasWarranty (
    ProductID int not null,
    WarrantyID int not null,
    primary key (ProductID,WarrantyID),
    foreign key (ProductID)
        references Product (ProductID) on delete cascade,
    foreign key (WarrantyID)
        references Warranty (WarrantyID) on delete cascade
);

------------------------------------------------
--  DDL Statements for table WriteReview
------------------------------------------------

CREATE TABLE WriteReview (
    FirstName varchar(60) not null,
    LastName varchar(60) not null,
    DateOfBirth Date not null,
    ProductID int not null,
    Star int not null,
    Comment varchar(2000) not null,
    primary key (FirstName,LastName,DateOfBirth,ProductID),
    foreign key (FirstName,LastName,DateOfBirth)
        references Person (FirstName,LastName,DateOfBirth) on delete cascade,
    foreign key (ProductID)
        references Product (ProductID) on delete cascade
);