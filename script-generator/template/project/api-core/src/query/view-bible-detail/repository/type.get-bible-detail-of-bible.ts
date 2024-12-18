

export type GetBibleDetailOfBibleInput = {
	id?: string
	page?: number
	size?: number
	search?: string

}

export type GetBibleDetailOfBibleOutPut = {
	items: Items[],
	total: number
}
export type Items = {
	id: string
	status: string
	medCode: string
	medGroup: string
	stopPeriod: string,
	medId: string,
	ingredient: {
	  activeIngredient: string
	  qty: number
	}[],
  
  }