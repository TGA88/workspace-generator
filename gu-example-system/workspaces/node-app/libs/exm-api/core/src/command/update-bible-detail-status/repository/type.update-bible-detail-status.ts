export type UpdateBibleDetailStatusInput = {
  id: string;
  bibleId: string;
  status: string;
  uid?: string;
  updateBy?: string;
};

export type UpdateBibleDetailStatusOutput = {
  id: string;
};
