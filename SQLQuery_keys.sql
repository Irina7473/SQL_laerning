USE [Sportshop]
GO


--¬Õ≈ÿÕ»≈  Àﬁ◊»
ALTER TABLE [dbo].[Table_Selling]  WITH CHECK ADD  CONSTRAINT [FK_Table_Selling_Table_Products] FOREIGN KEY([Product_id])
REFERENCES [dbo].[Table_Products] ([Id_Product])
ON DELETE SET DEFAULT
GO

ALTER TABLE [dbo].[Table_Selling] CHECK CONSTRAINT [FK_Table_Selling_Table_Products]
GO


ALTER TABLE [dbo].[Table_Selling]  WITH CHECK ADD  CONSTRAINT [FK_Table_Selling_Table_Employees] FOREIGN KEY([Seller_id])
REFERENCES [dbo].[Table_Employees] ([Id_Employee])
ON UPDATE CASCADE
ON DELETE SET NULL
GO

ALTER TABLE [dbo].[Table_Selling] CHECK CONSTRAINT [FK_Table_Selling_Table_Employees]
GO


ALTER TABLE [dbo].[Table_Selling]  WITH CHECK ADD  CONSTRAINT [FK_Table_Selling_Table_Clients] FOREIGN KEY([Customer_id])
REFERENCES [dbo].[Table_Clients] ([Id_Client])
ON UPDATE CASCADE
ON DELETE SET NULL
GO

ALTER TABLE [dbo].[Table_Selling] CHECK CONSTRAINT [FK_Table_Selling_Table_Clients]
GO


ALTER TABLE [dbo].[Table_Last_unit]  WITH CHECK ADD  CONSTRAINT [FK_Table_Last_unit_Table_Products] FOREIGN KEY([Product_id])
REFERENCES [dbo].[Table_Products] ([Id_Product])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Table_Last_unit] CHECK CONSTRAINT [FK_Table_Last_unit_Table_Products]
GO








