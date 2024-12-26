module Billing where

import Data.Map (Map)
import qualified Data.Map as Map

import Data.Set (Set)
import qualified Data.Set as Set

type Customer = String
type Product = String

type CustomerBillMap = Map Customer Double
type ProductCustomerMap = Map Product (Set Customer)

-- An order of some positive quantity of a product by a customer

data Order = Order Customer Product Int
    deriving (Show)

-- Prices for some products

type PriceList = Map Product Double

-- a list (without repetitions) of all the products that have been ordered.

products :: [Order] -> [Product]
products orders = Set.toList(Set.fromList (map (\(Order _ product _) -> product) orders))

-- a list of products that have been ordered but were not in the price list,
-- each with a list of the customers who ordered them (without repetitions).

unavailable :: [Order] -> PriceList -> [(Product, [Customer])]
unavailable orders prices = Map.toList $ fmap Set.toList $ foldr addUnavailableProduct Map.empty orders
  where
    addUnavailableProduct :: Order -> ProductCustomerMap -> ProductCustomerMap -- Add an unavailable product and its customers to the map
    addUnavailableProduct (Order customer product _) productCustomerMap
      | Map.lookup product prices == Nothing = Map.insertWith Set.union product (Set.singleton customer) productCustomerMap -- insertWith applies function to the existing value if the key is already present - avoids key existence checks so more efficient
      | otherwise = productCustomerMap

-- a list of customers who ordered products in the price list,
-- together with the total value of the products they ordered.

bill :: [Order] -> PriceList -> [(Customer, Double)]
bill orders prices = Map.toList $ foldr addOrderToBill Map.empty orders
  where
    addOrderToBill :: Order -> CustomerBillMap -> CustomerBillMap
    addOrderToBill (Order customer product quantity) customerBillMap
      | Just price <- Map.lookup product prices = Map.insertWith (+) customer (fromIntegral quantity * price) customerBillMap
      | otherwise = customerBillMap

-- like bill, but applying a "buy one, get one free" discounting policy,
-- i.e. if a customer orders 4 of a given product, they pay for 2;
-- if they order 5, they pay for 3.

bill_discount :: [Order] -> PriceList -> [(Customer, Double)]
bill_discount orders prices = Map.toList $ foldr addDiscountedOrderToBill Map.empty orders
  where
    addDiscountedOrderToBill :: Order -> CustomerBillMap -> CustomerBillMap
    addDiscountedOrderToBill (Order customer product quantity) customerBillMap
      | Just price <- Map.lookup product prices = Map.insertWith (+) customer (discountedPrice quantity * price) customerBillMap
      | otherwise = customerBillMap

    discountedPrice :: Int -> Double
    discountedPrice quantity = fromIntegral (quantity `div` 2 + quantity `mod` 2)

