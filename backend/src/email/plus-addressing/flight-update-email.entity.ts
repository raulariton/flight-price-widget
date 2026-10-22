import { Entity, Column, PrimaryColumn, CreateDateColumn } from 'typeorm';

@Entity()
export class FlightUpdateEmail {
  @PrimaryColumn({ unique: true })
  id: string;

  @Column()
  currentPrice: number;

  @Column()
  currencyCode: string;

  @CreateDateColumn({ type: "datetime" })
  processedAt: Date;
}