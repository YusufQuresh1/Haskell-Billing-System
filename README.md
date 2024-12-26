# Haskell-Billing-System
A Haskell program to manage orders and generate customer bills. Features include product listing, identifying unavailable products, calculating total bills, and applying "buy one, get one free" discounts. Implements efficient functional programming techniques with maps and sets.

products :: [Order] -> [Product]
a list (without repetitions) of all the products that have been ordered.

unavailable :: [Order] -> PriceList -> [(Product, [Customer])]
a list of products that have been ordered but were not in the price list, each with a list of the
customers who ordered them (without repetitions).

bill :: [Order] -> PriceList -> [(Customer, Double)]
a list of customers who ordered products in the price list, together with the total value of the
products they ordered.

bill_discount :: [Order] -> PriceList -> [(Customer, Double)]
like bill, but applying a “buy one, get one free” discounting policy, i.e. if a customer orders 4
of a given product, they pay for 2; if they order 5, they pay for 3.
