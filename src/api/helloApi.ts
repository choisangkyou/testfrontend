import { api } from "./axiosConfig";

export const getHello = async () => {
  const response = await api.get("/hello");
  return response.data;
};
