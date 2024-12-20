export type InputModel = {
  id: string;
  page?: number;
  size?: number;
  search?: string

};

export type BibleDetail = {
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



export type OutputModel = BibleDetail & {
  items: Items[];
  total: number;
};
