export type DeleteBibleDetailInput = {
  id: string;
  bibleId: string;
  uid?: string;
  updateBy?: string;
};

export type DeleteBibleDetailOutput = {
  id: string;
};
