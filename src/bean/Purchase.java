package bean;

public class Purchase {
	private int Purchase_ID;
	private String userID;
	private String Cart_ID;
	private String Purchase_Datetime;
	private int Total_Amount;
	private String Shipping_Address;
	private int Payment_ID;

	public int getPurchase_ID() {
		return Purchase_ID;
	}
	public void setPurchase_ID(int Purchase_ID) {
		this.Purchase_ID = Purchase_ID;
	}

	public String getuserID() {
		return userID;
	}
	public void setuserID(String userID) {
		this.userID = userID;
	}

	public String getCart_ID() {
		return Cart_ID;
	}
	public void set(String Cart_ID) {
		this.Cart_ID = Cart_ID;
	}

	public String getPurchase_Datetime() {
		return Purchase_Datetime;
	}
	public void setPurchase_Datetime(String Purchase_Datetime) {
		this.Purchase_Datetime = Purchase_Datetime;
	}

	public int getTotal_Amount() {
		return Total_Amount;
	}
	public void setTotal_Amount(int Total_Amount) {
		this.Total_Amount = Total_Amount;
	}

	public String getShipping_Address() {
		return Shipping_Address;
	}
	public void setShipping_Address(String Shipping_Address) {
		this.Shipping_Address= Shipping_Address;
	}

	public int getPayment_ID() {
		return Payment_ID;
	}
	public void setPayment_ID(int Payment_ID) {
		this.Payment_ID = Payment_ID;
	}

}