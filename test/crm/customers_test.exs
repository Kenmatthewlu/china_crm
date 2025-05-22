defmodule Crm.CustomersTest do
  use Crm.DataCase

  alias Crm.Customers

  describe "customers" do
    alias Crm.Customers.Customer

    import Crm.CustomersFixtures

    @invalid_attrs %{person_in_charge: nil, email: nil, company_address: nil, warehouse_address: nil, phone: nil}

    test "list_customers/0 returns all customers" do
      customer = customer_fixture()
      assert Customers.list_customers() == [customer]
    end

    test "get_customer!/1 returns the customer with given id" do
      customer = customer_fixture()
      assert Customers.get_customer!(customer.id) == customer
    end

    test "create_customer/1 with valid data creates a customer" do
      valid_attrs = %{person_in_charge: "some person_in_charge", email: "some email", company_address: "some company_address", warehouse_address: "some warehouse_address", phone: "some phone"}

      assert {:ok, %Customer{} = customer} = Customers.create_customer(valid_attrs)
      assert customer.person_in_charge == "some person_in_charge"
      assert customer.email == "some email"
      assert customer.company_address == "some company_address"
      assert customer.warehouse_address == "some warehouse_address"
      assert customer.phone == "some phone"
    end

    test "create_customer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_customer(@invalid_attrs)
    end

    test "update_customer/2 with valid data updates the customer" do
      customer = customer_fixture()
      update_attrs = %{person_in_charge: "some updated person_in_charge", email: "some updated email", company_address: "some updated company_address", warehouse_address: "some updated warehouse_address", phone: "some updated phone"}

      assert {:ok, %Customer{} = customer} = Customers.update_customer(customer, update_attrs)
      assert customer.person_in_charge == "some updated person_in_charge"
      assert customer.email == "some updated email"
      assert customer.company_address == "some updated company_address"
      assert customer.warehouse_address == "some updated warehouse_address"
      assert customer.phone == "some updated phone"
    end

    test "update_customer/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      assert {:error, %Ecto.Changeset{}} = Customers.update_customer(customer, @invalid_attrs)
      assert customer == Customers.get_customer!(customer.id)
    end

    test "delete_customer/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Customers.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> Customers.get_customer!(customer.id) end
    end

    test "change_customer/1 returns a customer changeset" do
      customer = customer_fixture()
      assert %Ecto.Changeset{} = Customers.change_customer(customer)
    end
  end
end
