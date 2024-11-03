export interface User {
  id: number;
  name: string;
  email: string;
  created_at: string;
}

export interface ResourceData<R> {
  data: R;
}

export interface APIError {
  error: string;
}
