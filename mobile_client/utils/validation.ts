export const VALID_UNIVERSITY_DOMAINS = [
  '.ac.rw',
  'alustudent.com',
  'alueducation.com'
  
];

export const isValidUniversityEmail = (email: string): boolean => {
  return VALID_UNIVERSITY_DOMAINS.some(domain => email.toLowerCase().endsWith(domain));
};