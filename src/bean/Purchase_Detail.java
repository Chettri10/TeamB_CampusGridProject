package bean;

import java.io.Serializable;

public class Purchase_Detail implements Serializable {
	private int Purchase_Details_ID;
	private int Purchase_ID;
	private int Product_ID;
	private int Cart_Details_ID;
	private int Unit_Price;
	private int Quantity;

	public int getPurchase_Detail_ID() {
		return Purchase_Details_ID;
	}
	public void setPurchase_Details_ID(int Purchase_Details_ID) {
		this.Purchase_Details_ID = Purchase_Details_ID;
	}


	public int getPurchase_ID() {
		return Purchase_ID;
	}
	public void setPurchase_ID(int Purchase_ID) {
		this.Purchase_ID = Purchase_ID;
	}

	public int getProduct_ID() {
		return Product_ID;
	}
	public void setProduct_ID(int Product_ID) {
		this.Product_ID = Product_ID;
	}

	public int getCart_Details_ID() {
		return Cart_Details_ID;
	}
	public void setCart_Details_ID(int Cart_Details_ID) {
		this.Cart_Details_ID = Cart_Details_ID;
	}

	public int getUnit_Price() {
		return Unit_Price;
	}
	public void setUnit_Price(int Unit_Price) {
		this.Unit_Price = Unit_Price;
	}

	public int getQuantity() {
		return Quantity;
	}
	public void setQuantity(int Quantity) {
		this.Quantity = Quantity;
	}


}
