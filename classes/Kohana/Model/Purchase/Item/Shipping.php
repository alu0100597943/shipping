<?php defined('SYSPATH') OR die('No direct script access.');

/**
 * @package    openbuildings\shipping
 * @author     Haralan Dobrev <hkdobrev@gmail.com>
 * @copyright  2013 OpenBuildings, Inc.
 * @license    http://spdx.org/licenses/BSD-3-Clause
 */
class Kohana_Model_Purchase_Item_Shipping extends Model_Purchase_Item {

	/**
	 * @codeCoverageIgnore
	 */
	public static function initialize(Jam_Meta $meta)
	{
		parent::initialize($meta);

		$meta
			->table('purchase_items')
			->associations(array(
				'shipping_item' => Jam::association('hasone', array(
					'inverse_of' => 'purchase_item',
					'dependent' => Jam_Association::DELETE
				)),
			))
			->fields(array(
				'is_payable' => Jam::field('boolean', array(
					'default' => TRUE
				))
			));
	}

	public function get_price()
	{
		return $this->get_reference_paranoid()->price_for_purchase_item($this);
	}
}