import { Items } from "../model"

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