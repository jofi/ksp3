#!/usr/bin/env ruby
class Dlazdica
  attr_reader :riadok, :stlpec, :hodnota

  def initialize(chodba, riadok, stlpec, hodnota)
    @chodba = chodba
    @riadok = riadok
    @stlpec = stlpec
    @hodnota = hodnota
  end

  def dlazdica_nad
    @dlazdica_nad ||= @chodba.dlazdica(@riadok - 1, @stlpec)
    @dlazdica_nad
  end

  def dlazdica_vlavo
    @dlazdica_vlavo ||= @chodba.dlazdica(@riadok, @stlpec - 1)
    @dlazdica_vlavo
  end

  def suma
    return @suma if @suma
    if lepsi_sused.nil?
      @suma = @hodnota
    else
      @suma = lepsi_sused.suma + @hodnota
    end
    @suma
  end

  def smer
    if (@riadok == 1) && (@stlpec == 1)
      @smer ||= '-'
    end
    @smer ||= begin
      vlavo = dlazdica_vlavo ? dlazdica_vlavo.suma : 0
      nad = dlazdica_nad ? dlazdica_nad.suma : 0
      sm = vlavo > nad ? 'R' : 'D'
      sm
    end
    @smer
  end

  def lepsi_sused
    return @lepsi_sused if @lepsi_sused
    @lepsi_sused ||= begin
      vlavo = dlazdica_vlavo ? dlazdica_vlavo.suma : 0
      nad = dlazdica_nad ? dlazdica_nad.suma : 0
      lepsi = vlavo > nad ? dlazdica_vlavo : dlazdica_nad
      lepsi
    end
    @lepsi_sused
  end

  def to_s
    "[#{riadok}, #{stlpec}]=#{hodnota}"
  end
end

class Chodba

  def self.prazdna_dlazdica(chodba)
    @@prazdna ||= Dlazdica.new(chodba, 0,0,0)
    @@prazdna
  end

  def self.zo_suboru(subor)
    prvy_riadok = true
    chodba = nil
    File.open(subor, 'r').each do |akt_riadok|
      if prvy_riadok
        riadkov, stlpcov = akt_riadok.split(' ')
        chodba = Chodba.new(riadkov.to_i, stlpcov.to_i)
        prvy_riadok = false
        next
      end
      chodba.pridaj_riadok(akt_riadok.split(' '))
    end
    chodba.zrataj!
    chodba
  end

  def initialize(riadkov, stlpcov)
    @dlazdice = []
    @riadkov = riadkov
    @stlpcov = stlpcov
  end

  def pridaj_riadok(riadok)
    @dlazdice << Array.new(0)
    cislo_stlpca = 1
    posl_riadok = @dlazdice.length
    riadok.each do |hodnota|
      @dlazdice[posl_riadok - 1] << Dlazdica.new(self, posl_riadok, cislo_stlpca, hodnota.to_i)
      cislo_stlpca += 1
    end
  end

  def zrataj!
    (1..@riadkov).each do |r|
      (1..@stlpcov).each do |s|
        #puts "[#{r},#{s}]"
        dlazdica(r,s).suma
      end
    end
    # @dlazdice.each do |row|
      # row.each do |col|
        # col.suma
      # end
    # end
  end

  def dlazdica(riadok, stlpec)
    if (riadok == 0) || (stlpec == 0)
      return nil #Chodba.prazdna_dlazdica(self)
    end
    @dlazdice[riadok - 1][stlpec - 1]
  end

  def suma
    dlazdica(@riadkov, @stlpcov).suma
  end

  def cesta
    cesta_odzadu = []
    dlazdica = dlazdica(@riadkov, @stlpcov)
    while dlazdica
      cesta_odzadu << dlazdica.smer
      dlazdica = dlazdica.lepsi_sused
    end

    cesta_odzadu.reverse
  end

  def vypis_dlazdice(&block)
    @dlazdice.each do |row|
      row.each do |col|
        block.call(col)
      end
      puts
    end
  end

  def vypis_hodnoty
    vypis_dlazdice do |dlazdica|
        printf("%4d", dlazdica.hodnota)
    end
  end

  def vypis_sumy
    vypis_dlazdice do |dlazdica|
        printf("%4d", dlazdica.suma)
    end
  end

  def vypis_smery
    vypis_dlazdice do |dlazdica|
        printf("%4s", dlazdica.smer)
    end
  end

  def vypis_cestu
    puts cesta.join('')
  end
end

if __FILE__ == $0
  vstup = ARGV[0]
  @chodba = Chodba.zo_suboru(vstup)
  #@chodba.vypis_hodnoty
  #puts
  #@chodba.vypis_sumy
  #puts
  #@chodba.vypis_smery
  #puts
  puts @chodba.suma
  puts @chodba.cesta
end
