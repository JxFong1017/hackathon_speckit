export const employers = [
  { id: 'employer-north', name: 'North Ferry Co' },
  { id: 'employer-harbour', name: 'Harbour Lane Pty Ltd' },
  { id: 'employer-brightpath', name: 'Brightpath Group' },
] as const;

export type Employer = (typeof employers)[number];
export type EmployerId = Employer['id'];

export const talentContract = {
  id: 'contract-roster',
  label: 'Roster cover contract',
} as const;

export function findEmployer(id: string): Employer | undefined {
  return employers.find((employer) => employer.id === id);
}
