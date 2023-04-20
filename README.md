# NashvilleHousing SQL Data Cleaning

This is SQL code that cleans and standardizes the data in a table named "NashvilleHousing" within a database named "PortofolioProject". The code performs the following tasks:

- Standardizes the date format of the "SaleDate" column using either the CONVERT or CAST functions and updates the column in the table.
- Populates missing data in the "PropertyAddress" column by filling in data from the same "ParcelID", and updates the column in the table.
- Splits the "PropertyAddress" and "OwnerAddress" columns into individual columns for "Address", "City", and "State" using the SUBSTRING and PARSENAME functions, and updates the table.
- Converts the values in the "SoldAsVacant" column from "Y" or "N" to "Yes" or "No", and updates the column in the table.
- Removes duplicates using the ROW_NUMBER function.
