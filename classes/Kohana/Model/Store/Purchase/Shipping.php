<?php defined('SYSPATH') OR die('No direct script access.');

/**
 * @package    openbuildings\shipping
 * @author     Ivan Kerin <ikerin@gmail.com>
 * @copyright  (c) 2013 OpenBuildings Ltd.
 * @license    http://spdx.org/licenses/BSD-3-Clause
 */
class Kohana_Model_Store_Purchase_Shipping extends Jam_Model implements Sellable {

	/**
	 * @codeCoverageIgnore
	 */
	public static function initialize(Jam_Meta $meta)
	{
		$meta
			->behaviors(array(
				'freezable' => Jam::behavior('freezable', array('children' => 'items', 'parent' => 'store_purchase')),
			))
			->associations(array(
				'store_purchase' => Jam::association('belongsto', array('inverse_of' => 'shipping')),
				'items' => Jam::association('hasmany', array('foreign_model' => 'shipping_item', 'inverse_of' => 'store_purchase_shipping')),
			))
			->fields(array(
				'id' => Jam::field('primary'),
			))
			->validator('store_purchase', 'items', array('present' => TRUE));
	}

	/**
	 * Implement Sellable
	 * Returns the computed price of all of its items
	 * @param  Model_Purchase_Item $item
	 * @return Jam_Price
	 */
	public function price_for_purchase_item(Model_Purchase_Item $item)
	{
		$items = $this->items->as_array();

		return $this->compute_price($items);
	}

	/**
	 * Get the merge of all total_delivery_time ranges from the items
	 * By getting the maximum min and max amounts.
	 * @return Jam_Range
	 */
	public function total_delivery_time()
	{
		$times = array_map(function($item){
			return $item->total_delivery_time();
		}, $this->items->as_array());

		return Jam_Range::merge($times);
	}

	/**
	 * Total price for the purchased items
	 * @throws Kohana_Exception If store_purchase is NULL
	 * @return Jam_Price
	 */
	public function total_purchase_price()
	{
		return $this
			->get_insist('store_purchase')
				->total_price(array('is_payable' => TRUE));
	}

	/**
	 * Get the currency to be used in all the calculations
	 * @return string 
	 */
	public function currency()
	{
		return $this
			->get_insist('store_purchase')
				->currency();
	}

	/**
	 * Get the location to be used in all the calculations
	 * @return string 
	 */
	public function ship_to()
	{
		return $this
			->get_insist('store_purchase')
				->get_insist('purchase')
					->shipping_country();
	}

	/**
	 * Get the monetary object to be used in all the calculations
	 * @return Monetary 
	 */
	public function monetary()
	{
		return $this
			->get_insist('store_purchase')
				->monetary();
	}

	public function items_from(array $purchase_items)
	{
		Array_Util::validate_instance_of($purchase_items, 'Model_Purchase_Item');
		$purchase_item_ids = array_map(function($purchase_item){ return $purchase_item->id; }, $purchase_items);

		$items = $this->items->as_array('purchase_id');

		return array_intersect_key($items, array_flip($purchase_item_ids));
	}

	/**
	 * Build Shipping_Items based on purchase items and method, as well as the ship_to() method
	 * @param  array                 $purchase_items array of Model_Purchase_Item objects
	 * @param  Model_Shipping_Method $method
	 * @return $this
	 */
	public function build_items_from(array $purchase_items, Model_Shipping_Method $method = NULL)
	{
		$this->items = $this->new_items_from($purchase_items, $this->ship_to(), $method);

		return $this;
	}

	/**
	 * Build a single shipping_item and add it to the items of this store_purchase_shipping.
	 * @param  Model_Purchase_Item $purchase_item 
	 * @param  Model_Shipping_Method              $method
	 * @return Model_Store_Purchase_Shipping
	 */
	public function build_item_from(Model_Purchase_Item $purchase_item, Model_Shipping_Method $method = NULL)
	{
		$this->items []= $this->new_item_from($purchase_item, $this->ship_to(), $method);

		return $this;
	}

	/**
	 * Compute the price of shipping items, generated from the purchase_items.
	 * This method does not change the store_purchase_shipping object in any way.
	 * @param  array                 $purchase_items 
	 * @param  Model_Shipping_Method $method         
	 * @return Jam_Price
	 */
	public function compute_price_from(array $purchase_items, Model_Shipping_Method $method)
	{
		$shipping_items = $this->new_items_from($purchase_items, $this->ship_to(), $method);
		return $this->compute_price($shipping_items);
	}

	public function new_items_from(array $purchase_items, Model_Location $location, $method = NULL)
	{
		Array_Util::validate_instance_of($purchase_items, 'Model_Purchase_Item');

		$self = $this;

		return array_map(function($purchase_item) use ($location, $method, $self) {
			return $self->new_item_from($purchase_item, $location, $method);
		}, $purchase_items);
	}

	public function new_item_from(Model_Purchase_Item $purchase_item, Model_Location $location, Model_Shipping_Method $method = NULL)
	{
		$shipping = $purchase_item->get_insist('reference')->shipping();

		return Jam::build('shipping_item', array(
			'store_purchase_shipping' => $this,
			'purchase_item' => $purchase_item,
			'shipping_group' => $method ? $shipping->group_for($location, $method) : $shipping->cheapest_group_in($location),
		));
	}

	/**
	 * Compute prices of Model_Shipping_Item filtering out discounted items,
	 * grouping by method and shipping_from, and calculating their relative prices
	 * @param  array     $items 
	 * @return Jam_Price
	 */
	public function compute_price(array $items)
	{
		$total = $this->total_purchase_price();

		Array_Util::validate_instance_of($items, 'Model_Shipping_Item');

		$items = Model_Shipping_Item::filter_discounted_items($items, $total);

		$groups = Array_Util::group_by($items, function($item){
			return $item->group_key();
		});

		$group_prices = array_map(function($grouped_items) use ($total) {
			$prices = Model_Shipping_Item::relative_prices($grouped_items);
			return Jam_Price::sum($prices, $total->currency(), $total->monetary());
		}, $groups);

		return Jam_Price::sum($group_prices, $total->currency(), $total->monetary());
	}

}