package bean;

import java.io.Serializable;

public class Payment  implements Serializable {
	private int Payment_ID;
	private int Payment_Type;

	public int getPayment_ID() {
		return Payment_ID;
	}
	public void setPayment_ID(int Payment_ID) {
		this.Payment_ID =Payment_ID;
	}
	public int getPayment_Type() {
		return Payment_Type;
	}
	public void setPayment_Type(int Payment_Type) {
		this.Payment_Type = Payment_Type;
	}

}
