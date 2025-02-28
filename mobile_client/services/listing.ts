import api from './api';

export interface Listing {
  id: string;
  name: string;  // This might be what you're using as title
  description: string;
  price: number;
  location: string;
  images: string[];
  user: {
    name: string;
    email: string;
    profilePhoto?: string;
  };
}

export const listingService = {
  async getListings(filters?: {
    type?: string;
    priceMin?: number;
    priceMax?: number;
    location?: string;
    amenities?: string[];
  }): Promise<Listing[]> {
    const response = await api.get('/listings', { params: filters });
    // Format the price to string before returning
    return response.data.map((listing: any) => ({
      ...listing,
      price: typeof listing.price === 'number' 
        ? `RWF ${listing.price.toLocaleString()}/month`
        : listing.price
    }));
  },

  async getListing(id: string): Promise<Listing> {
    const response = await api.get(`/listings/${id}`);
    return response.data;
  },

  async createListing(data: Partial<Listing>): Promise<Listing> {
    const response = await api.post('/listings', data);
    return response.data;
  },

  async updateListing(id: string, data: Partial<Listing>): Promise<Listing> {
    const response = await api.put(`/listings/${id}`, data);
    return response.data;
  },

  async deleteListing(id: string): Promise<void> {
    await api.delete(`/listings/${id}`);
  },

  async uploadListingImages(id: string, images: FormData): Promise<string[]> {
    const response = await api.post(`/listings/${id}/images`, images, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data.urls;
  },
};