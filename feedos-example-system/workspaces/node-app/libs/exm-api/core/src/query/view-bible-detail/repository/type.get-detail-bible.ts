

export type GetDetailBibleInput = {
	id: string
}

export type GetDetailBibleOutput = BibleDetail

type BibleDetail = {
	id: string;
	status: string;
	year: number
	cancelRemark: string
	country: {
	  countryCode: string;
	  countryName: string;
	};
	animalType: {
	  animalTypeCode: string;
	  animalTypeName: string;
	}[];
	species: {
	  speciesCode: string
	  speciesName: string
	}
	createBy: string;
	updateBy: string;
	createAt: Date;
	updateAt: Date;
	remarks: string;
	medType: {
	  medTypeCode: string,
	  medTypeName: string
	},
  
  };