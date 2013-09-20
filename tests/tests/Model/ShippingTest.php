<?php

use OpenBuildings\Monetary\Monetary;
use OpenBuildings\Monetary\Source_Static;

/**
 * Functest_TestsTest 
 *
 * @group model.shipping
 * 
 * @package Functest
 * @author Ivan Kerin
 * @copyright  (c) 2011-2013 Despark Ltd.
 */
class Model_ShippingTest extends Testcase_Shipping {

	public function data_currency()
	{
		return array(
			array('GBP'),
			array('EUR'),
		);
	}

	/**
	 * @dataProvider data_currency
	 * @covers Model_Shipping::currency
	 */
	public function test_currency($currency)
	{
		$shipping = Jam::build('shipping', array('currency' => $currency));

		$this->assertEquals($currency, $shipping->currency());
	}

	public function data_locations_containing()
	{
		return array(
			array('Everywhere', array(1)),
			array('Europe', array(1, 2)),
			array('France', array(1, 2, 3)),
		);
	}

	/**
	 * @covers Model_Shipping::methods_group_key
	 */
	public function test_methods_group_key()
	{
		$shipping = Jam::find('shipping', 1);

		$this->assertEquals('1,2,3', $shipping->methods_group_key());
	}

	/**
	 * @dataProvider data_locations_containing
	 * @covers Model_Shipping::locations_containing
	 */
	public function test_locations_containing($location_name, $expected_location_ids)
	{
		$shipping = Jam::find('shipping', 1);

		$location = Jam::find('location', $location_name);

		$locations_containing = $shipping->locations_containing($location);

		$this->assertEquals($expected_location_ids, $this->ids($locations_containing));
	}

	public function data_ships_to()
	{
		return array(
			array('France', TRUE),
			array('Germany', TRUE),
			array('Turkey', TRUE),
			array('United Kingdom', TRUE),
			array('Russia', FALSE),
		);
	}

	/**
	 * @dataProvider data_ships_to
	 * @covers Model_Shipping::ships_to
	 */
	public function test_ships_to($location_name, $expected_ships_to)
	{
		$shipping = Jam::find('shipping', 1);

		$location = Jam::find('location', $location_name);

		$ships_to = $shipping->ships_to($location);

		$this->assertEquals($expected_ships_to, $ships_to);
	}

	public function data_most_specific_location_for()
	{
		return array(
			array('France', 'France'),
			array('Germany', 'Europe'),
			array('United Kingdom', 'Europe'),
		);
	}

	/**
	 * @dataProvider data_most_specific_location_for
	 * @covers Model_Shipping::most_specific_location_containing
	 */
	public function test_most_specific_location_for($location_name, $expected_location_name)
	{
		$shipping = Jam::find('shipping', 1);

		$location = Jam::find('location', $location_name);

		$specific_location = $shipping->most_specific_location_containing($location);

		$this->assertEquals($expected_location_name, $specific_location->name());
	}

	public function data_groups_in()
	{
		return array(
			array('France', array(4, 5)),
			array('Germany', array(2)),
			array('Australia', array(1)),
		);
	}

	/**
	 * @dataProvider data_groups_in
	 * @covers Model_Shipping::groups_in
	 */
	public function test_groups_in($location_name, $expected_group_ids)
	{
		$shipping = Jam::find('shipping', 1);

		$location = Jam::find('location', $location_name);

		$groups = $shipping->groups_in($location);

		$this->assertEquals($expected_group_ids, $this->ids($groups));
	}

	/**
	 * @covers Model_Shipping::cheapest_group_in
	 */
	public function test_cheapest_group_in()
	{
		$monetary = new Monetary('GBP', new Source_Static());
		$france = Jam::find('location', 'France');
		$shipping = $this->getMock('Model_Shipping', array('groups_in'), array('shipping'));

		$params = array(
			array('id' => 10, 'price' => new Jam_Price(20, 'USD', $monetary)), 
			array('id' => 11, 'price' => new Jam_Price(18, 'GBP', $monetary)),
			array('id' => 12, 'price' => new Jam_Price(5, 'USD', $monetary)),
		);

		$groups = $this->buildModelArray('shipping_group', $params);

		$shipping
			->expects($this->once())
			->method('groups_in')
			->with($this->identicalTo($france))
			->will($this->returnValue($groups));

		$group = $shipping->cheapest_group_in($france);

		$this->assertInstanceOf('Model_Shipping_Group', $group);
		$this->assertEquals(12, $group->id());
	}

	public function data_group_for()
	{
		return array(
			array('France', 1, 5),
			array('Germany', 2, 2),
			array('Australia', 1, 1),
			array('Australia', 2, NULL),
		);
	}

	/**
	 * @dataProvider data_group_for
	 * @covers Model_Shipping::group_for
	 */
	public function test_group_for($location_name, $method_id, $expected)
	{
		$shipping = Jam::find('shipping', 1);

		$location = Jam::find('location', $location_name);
		$method = Jam::find('shipping_method', $method_id);

		$group = $shipping->group_for($location, $method);

		if ($expected) 
		{
			$this->assertNotNull($group);
			$this->assertEquals($expected, $group->id());
		}
		else
		{
			$this->assertNull($group);
		}
	}

	/**
	 * @covers Model_Shipping::delivery_time_for
	 */
	public function test_delivery_time_for()
	{
		$france = Jam::find('location', 'France');
		$shipping = $this->getMock('Model_Shipping', array('groups_in'), array('shipping'));

		$group1 = Jam::build('shipping_group', array('delivery_time' => new Jam_Range(array(10, 20))));
		$group2 = Jam::build('shipping_group', array('delivery_time' => new Jam_Range(array(13, 12))));

		$shipping
			->expects($this->at(0))
			->method('groups_in')
			->with($this->identicalTo($france))
			->will($this->returnValue(NULL));

		$shipping
			->expects($this->at(1))
			->method('groups_in')
			->with($this->identicalTo($france))
			->will($this->returnValue(array($group1, $group2)));

		$this->assertNull($shipping->delivery_time_for($france));

		$this->assertEquals(new Jam_Range(array(13, 20)), $shipping->delivery_time_for($france));
	}

	/**
	 * @covers Model_Shipping::total_delivery_time_for
	 */
	public function test_total_delivery_time_for()
	{
		$france = Jam::find('location', 'France');
		$shipping = $this->getMock('Model_Shipping', array('delivery_time_for'), array('shipping'));
		$shipping->processing_time = new Jam_Range(array(3, 5));

		$shipping
			->expects($this->at(0))
			->method('delivery_time_for')
			->with($this->identicalTo($france))
			->will($this->returnValue(NULL));

		$shipping
			->expects($this->at(1))
			->method('delivery_time_for')
			->with($this->identicalTo($france))
			->will($this->returnValue(new Jam_Range(array(12, 32))));

		$this->assertNull($shipping->total_delivery_time_for($france));

		$this->assertEquals(new Jam_Range(array(15, 37)), $shipping->total_delivery_time_for($france));
	}
}