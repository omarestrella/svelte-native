export type Feed = {
  title: string;
  items: FeedItem[];
};
export type FeedItem = {
  title: string;
  description: string;
  date: string;
  content: string;
  link: string;
};
